import os
import sys
import time
from datetime import datetime
import glob
import subprocess
import psycopg2 as sql
import sqlparse
from io import StringIO
from concurrent.futures import ProcessPoolExecutor
from concurrent.futures import as_completed
from importlib import import_module

log = import_module('write_log', os.getcwd() + '\\write_log.py').Log('mapping_util')
db_conf = import_module('__postgres_db_conf', os.getcwd() +'\\__postgres_db_conf.py').db_conf

# ---------------------------------------------------------
def calc_time(secs_tot):
	"calculate the time as h, m and sec from seconds"
# ---------------------------------------------------------
	(mins, secs) = divmod(secs_tot, 60)
	(hours, mins) = divmod(mins, 60)
	return("{0}h:{1:02d}m:{2:02d}s".format(int(hours), int(mins), int(secs)))

# ---------------------------------------------------------
def does_tbl_exist(cnx, tbl_name):
	"Check if a table exists in he current database"
# ---------------------------------------------------------
	ret 	= True
	exist 	= False
	cursor1 = None

	try:
		cursor1 = cnx.cursor()
		pos = tbl_name.find('.')
		if pos == -1:
			schema_name = 'public'
		else:
			lst = tbl_name.split(".", 1)
			schema_name = lst[0]
			tbl_name = lst[1]
		sql_exec = "SELECT COUNT(*) \
			FROM pg_tables \
			WHERE schemaname = '" + schema_name + "' \
			AND tablename = '" + tbl_name + "'"
		cursor1.execute(sql_exec)
		row = cursor1.fetchone()
		if row[0] > 0:
			exist = True
		cursor1.close()
	except:
		ret = False
		err = sys.exc_info()
		print("Function = {0}, Error = {1}, {2}".format("does_tbl_exist", err[0], err[1]))
		if cursor1 != None:
			cursor1.close()
	return(ret, exist)	

# ---------------------------------------------------------
def load_files(schema, tbl_name, file_list, dir_processed):
	"Load files into tables"
# ---------------------------------------------------------
	ret = True
	
	try:
		print("load_files 1")
# ---------------------------------------------------------
# Connect to db
# ---------------------------------------------------------
# If list is not empty
		if file_list:
			cnx = sql.connect(
				user=db_conf['username'],
				password=db_conf['password'],
				database=db_conf['database']
			)
			cnx.autocommit = True
			cursor1 = cnx.cursor()
			cursor1.execute('SET datestyle TO \'' + db_conf['datestyle'] + '\'')
			cursor1.execute('SET search_path TO ' + schema)
# ---------------------------------------------------------
			time1 = time.time()
# ---------------------------------------------------------
			file_list_full = []
			for i in range(len(file_list)):
				for f in glob.iglob(file_list[i]):
					file_list_full.append(f)
			for fname in file_list_full:
				print("File = {0}".format(fname))
# ---------------------------------------------------------
# Load - Delimiter is TAB
# ---------------------------------------------------------
				stream = StringIO()
				stream.write(open(fname, errors = 'ignore').read().replace('\\', ''))
				stream.seek(0)
				stream.readline()	#To avoid headers
				cursor1.copy_from(stream, tbl_name, sep = '	', null = '')
# ---------------------------------------------------------
# Move loaded file to PROCESSED directory
# ---------------------------------------------------------
				file_processed = dir_processed + os.path.basename(fname)
				os.rename(fname, file_processed)
			cursor1.close()
			cnx.close()
			processing_time = "Files loaded in {0}".format(calc_time(time.time() - time1))
			print(processing_time)
# ---------------------------------------------------------
		print("load_files 2")
	except:
		ret = False
		err = sys.exc_info()
		print("Function = {0}, Error = {1}, {2}".format("load_files", err[0], err[1]))
	return(ret)

# ---------------------------------------------------------
def load_files_parallel(schema, tbl_list, file_list, dir_processed):
	"Load files into tables"
# ---------------------------------------------------------
	ret = True

	try:
		print("load_files_parallel 1")
		time1 = time.time()
# ---------------------------------------------------------
# Load files in parallel (all tables), sequentially within each table
# ---------------------------------------------------------
		with ProcessPoolExecutor(int(db_conf['max_workers'])) as executor:
			futures = [executor.submit(load_files, schema, tbl_name, file_list[idx], dir_processed) for idx, tbl_name in enumerate(tbl_list)]
			for future in as_completed(futures):
				if future.result() == False:
					ret = False
					log.log_message('load_files_parallel stopped with errors at ' + datetime.now().strftime("%d/%m/%Y, %H:%M:%S"))
					break
		if ret == True:
			msg = '\n[' + datetime.now().strftime("%d/%m/%Y, %H:%M:%S") + '] load_files_parallel execution time: '
			msg += calc_time(time.time() - time1) + "\n"
			log.log_message(msg)
# ---------------------------------------------------------
		print("load_files_parallel 2")
	except:
		ret = False
		err = sys.exc_info()
		print("Function = {0}, Error = {1}, {2}".format("load_files_parallel", err[0], err[1]))
	return(ret)


# ---------------------------------------------------------
def get_table_count(tbl_name, tbl_result, cnx = None):
# ---------------------------------------------------------
	ret 			= True
	new_connection 	= False
	cursor1 		= None

	try:
		if cnx == None:
			new_connection = True
			cnx = sql.connect(
				user=db_conf['username'],
				password=db_conf['password'],
				database=db_conf['database']
			)
			cnx.autocommit = True
		cursor1 = cnx.cursor()
# Check if table exists
		query1 = 'SELECT to_regclass(\'' + tbl_name + '\')';
		cursor1.execute(query1)
		present = cursor1.fetchone()[0]
		if present == None:
			records = '0'
# Count records
		else:
			query1 = 'select count(*) from ' + tbl_name
			cursor1.execute(query1)
			records = str(cursor1.fetchone()[0])
		schema_name, tbl_name_short = tbl_name.split(".")
# Store results in source_records
#		if "." in tbl_name:
		tbl_name_short = "\'" + tbl_name_short + "\'"
#		else:
#			tbl_name_short = tbl_name
		query1 = 'select * from ' + tbl_result + ' where tbl_name = ' + tbl_name_short
		cursor1.execute(query1)
		present = cursor1.fetchone()
		if present == None:
			query1 = 'insert INTO ' + tbl_result + ' (tbl_name, ' + schema_name + '_records) VALUES (' + tbl_name_short + ', ' + records + ')'
			cursor1.execute(query1)
			log.log_message(f'{tbl_name} row count: {records}')
		else:
			query1 = 'update ' + tbl_result + ' SET ' + schema_name + '_records = ' + records + ' where tbl_name = ' + tbl_name_short
			cursor1.execute(query1)
			log.log_message(f'{tbl_name} row count: {records}')
			query1 = 'update ' + tbl_result + ' SET total_records = COALESCE(source_records,0) + COALESCE(source_nok_records,0) where tbl_name = ' + tbl_name_short
			cursor1.execute(query1)
		cursor1.close()
		cursor1 = None
		if new_connection == True:
			cnx.close()
	except:
		ret = False
		err = sys.exc_info()
		print("Function = {0}, Error = {1}, {2}".format("get_table_count", err[0], err[1]))
		if cursor1 != None:
			cursor1.close()
		if new_connection == True:
			cnx.close()
	return(ret)	

# ---------------------------------------------------------
def get_table_count_parallel(tbl_list, tbl_records):
# ---------------------------------------------------------
	ret = True

	try:
		time1 = time.time()
		print(tbl_list)
		with ProcessPoolExecutor(int(db_conf['max_workers'])) as executor:
			futures = [executor.submit(get_table_count, tbl, tbl_records) for tbl in tbl_list]
			for future in as_completed(futures):
				if future.result() == False:
					ret = False
					msg = 'get_table_count_parallel stopped with error at ' + datetime.now().strftime("%d/%m/%Y, %H:%M:%S")
					break
		if ret == True:
			msg = '[' + datetime.now().strftime("%d/%m/%Y, %H:%M:%S") + '] get_table_count_parallel execution time: '
			msg += calc_time(time.time() - time1) + "\n"
		log.log_message(msg)
	except:
		ret = False
		err = sys.exc_info()
		print("Function = {0}, Error = {1}, {2}".format("get_table_count_parallel", err[0], err[1]))
	return(ret)	

# ---------------------------------------------------------
def parse_queries_file(filename, chunk_id=None):
# ---------------------------------------------------------
	source_nok_schema = db_conf['source_nok_schema'] if 'source_nok_schema' in db_conf else None
	source_schema = db_conf['source_schema'] if 'source_schema' in db_conf else None
	target_schema = db_conf['target_schema'] if 'target_schema' in db_conf else None
	vocabulary_schema = db_conf['vocabulary_schema'] if 'vocabulary_schema' in db_conf else None
	lookup_directory = db_conf['dir_lookup'] if 'dir_lookup' in db_conf else None
	vocabulary_directory = db_conf['dir_voc'] if 'dir_voc' in db_conf else None
	stcm_directory = db_conf['dir_stcm'] if 'dir_stcm' in db_conf else None
	medical_dictionary = db_conf['medical_dictionary_filename'] if 'medical_dictionary_filename' in db_conf else None
	product_dictionary = db_conf['product_dictionary_filename'] if 'product_dictionary_filename' in db_conf else None
	chunk_size = str(db_conf['chunk_size']) if 'chunk_size' in db_conf else None

	query_list = open(filename).read().split(';')
	for idx, item in enumerate(query_list):
		query = sqlparse.format(item, strip_comments=True).strip()
		query = query.replace('{SOURCE_NOK_SCHEMA}', source_nok_schema) if source_nok_schema is not None else query
		query = query.replace('{SOURCE_SCHEMA}', source_schema) if source_schema is not None else query
		query = query.replace('{TARGET_SCHEMA}', target_schema) if target_schema is not None else query
		query = query.replace('{VOCABULARY_SCHEMA}', vocabulary_schema) if vocabulary_schema is not None else query  
		query = query.replace('{LOOKUP_DIRECTORY}', lookup_directory) if lookup_directory is not None else query  
		query = query.replace('{VOCABULARY_DIRECTORY}', vocabulary_directory) if vocabulary_directory is not None else query  
		query = query.replace('{STCM_DIRECTORY}', stcm_directory) if stcm_directory is not None else query  
		query = query.replace('{MEDICAL_DICTIONARY}', medical_dictionary) if medical_dictionary is not None else query  
		query = query.replace('{PRODUCT_DICTIONARY}', product_dictionary) if product_dictionary is not None else query  
		query = query.replace('{CHUNK_SIZE}', chunk_size) if chunk_size is not None else query  
		query = query.replace('{CHUNK_ID}', chunk_id) if chunk_id is not None else query
		query_list[idx] = query
	return(query_list)

# ---------------------------------------------------------
def execute_query(query, debug = True):
# ---------------------------------------------------------
	ret = True
	
	try:
		cnx = sql.connect(
			user=db_conf['username'],
			password=db_conf['password'],
			database=db_conf['database']
		)
		cursor1 = cnx.cursor()
		cnx.autocommit = True
		if debug:
			time1 = time.time()
			msg = '[' + datetime.now().strftime("%d/%m/%Y, %H:%M:%S") + '] Processing: ' + query.split('\n')[0]
			log.log_message(msg)
		cursor1.execute(query)
		if debug:
			msg = '[' + datetime.now().strftime("%d/%m/%Y, %H:%M:%S") + '] Query execution time: '
			msg += calc_time(time.time() - time1) + "\n"
			log.log_message(msg)
		cursor1.close()
		cursor1 = None
		cnx.close()
	except:
		ret = False
		err = sys.exc_info()
		print("Function = {0}, Error = {1}, {2}".format("execute_query", err[0], err[1]))
		if cursor1 != None:
			cursor1.close()
		cnx.close()
	return(ret)	

# ---------------------------------------------------------
#def execute_multiple_queries(filename, chunk_id = None, cnx = None, save_progress = False, debug = False):
def execute_multiple_queries(filename, chunk_id = None, cnx = None, commit = True, debug = True):
# ---------------------------------------------------------
	ret 			= True
	new_connection 	= False
	
	try:
#		print(filename)
#		print(type(filename))
#		print("")
		if os.path.isfile(filename):
			if cnx == None:
				new_connection = True
				cnx = sql.connect(
					user=db_conf['username'],
					password=db_conf['password'],
					database=db_conf['database']
				)
				cnx.autocommit = commit
			cursor1 = cnx.cursor()
			queries = parse_queries_file(filename, chunk_id)
			for query in queries:
				if query != '':
					if debug:
						time1 = time.time()
						msg = '[' + datetime.now().strftime("%d/%m/%Y, %H:%M:%S") + '] Processing: ' + query.split('\n')[0]
						log.log_message(msg)
	#					log.log_message(query.split('\n')[0])
	#					log.log_message(query.replace('\r\n', ' '))
					cursor1.execute(query)
					if debug:
	#					msg = '[' + datetime.now().strftime("%d/%m/%Y, %H:%M:%S") + '] Query execution time: "
						msg = '[' + datetime.now().strftime("%d/%m/%Y, %H:%M:%S") + '] Finished  : ' + query.split('\n')[0] + ' in '
						msg += calc_time(time.time() - time1) + "\n"
						log.log_message(msg)
			dir_sql_processed = os.getcwd() + '\\sql_scripts' + db_conf['dir_processed']
			file_processed = dir_sql_processed + os.path.basename(filename)
			os.rename(filename, file_processed)
			cursor1.close()
			cursor1 = None
			if new_connection == True:
				cnx.close()
	except:
		ret = False
		err = sys.exc_info()
		print("Function = {0}, Error = {1}, {2}".format("execute_multiple_queries", err[0], err[1]))
		if cursor1 != None:
			cursor1.close()
		if new_connection == True:
			cnx.close()
	return(ret)	
		
# ---------------------------------------------------------
def execute_sql_file_parallel(fname, debug = True):
# The queries in the file are executed in parallel
# ---------------------------------------------------------
	ret = True

	try:
		time1 = time.time()
		query_list = parse_queries_file(fname)
		with ProcessPoolExecutor(int(db_conf['max_workers'])) as executor:
			futures = [executor.submit(execute_query, query, debug) for query in query_list if query != '']
# Retrieve the results in completion order
			for future in as_completed(futures):
				if future.result() == False:
					ret = False
					msg = 'execute_sql_file_parallel stopped with error at ' + datetime.now().strftime("%d/%m/%Y, %H:%M:%S")
					break
		if ret == True:
			msg = '[' + datetime.now().strftime("%d/%m/%Y, %H:%M:%S") + '] execute_sql_file_parallel execution time: '
			msg += calc_time(time.time() - time1) + "\n"
		log.log_message(msg)
	except:
		ret = False
		err = sys.exc_info()
		print("Function = {0}, Error = {1}, {2}".format("execute_sql_file_parallel", err[0], err[1]))
	return(ret)	

# ---------------------------------------------------------
def execute_sql_files_parallel(fname_list, debug = True): 
# The sql files are executed in parallel
# ---------------------------------------------------------
	ret = True

	try:
		time1 = time.time()
		fname_list = [fname for fname in fname_list if os.path.isfile(fname)]
		if len(fname_list) > 0:
			with ProcessPoolExecutor(int(db_conf['max_workers'])) as executor:
				futures = [executor.submit(execute_multiple_queries, fname, None, None, True, debug) for fname in fname_list]
				for future in as_completed(futures):
					if future.result() == False:
						ret = False
						msg = 'execute_sql_files_parallel stopped with error at ' + datetime.now().strftime("%d/%m/%Y, %H:%M:%S")
						break
			if ret == True:
#				processed_folder = os.path.dirname(fname_list[0]) + "\\processed\\"
#				for i in range(len(fname_list)):
#					fname = fname_list[i]
#					file_processed = processed_folder + os.path.basename(fname)
#					os.rename(fname, file_processed)
				msg = '[' + datetime.now().strftime("%d/%m/%Y, %H:%M:%S") + '] execute_sql_files_parallel execution time: '
				msg += calc_time(time.time() - time1) + "\n"
			log.log_message(msg)
	except:
		ret = False
		err = sys.exc_info()
		print("Function = {0}, Error = {1}, {2}".format("execute_sql_files_parallel", err[0], err[1]))
	return(ret)	


# ---------------------------------------------------------
def unzip_file(fname, dir_study, dir_downloaded, dir_data, debug = True):
# The queries in the file are executed in parallel
# ---------------------------------------------------------
	ret = True

	try:
# ---------------------------------------------------------
# Unzip and move to the processed directory
# 7zip command 'e'  = Extract
# 7zip command 'x'  = eXtract with full paths
# 7zip switch  '-o' = set Output directory. NO space between -o and the output directory (e.g. "-oC:\Temp")
# 7zip switch  '-bso0' = disable stream of standard output
# 7zip switch  '-aos' = skip extracting of existing files.
# ---------------------------------------------------------
		print("\nUnzipping file = {0}".format(fname))
# ---------------------------------------------------------
# Unzip with 7Z
# ---------------------------------------------------------
		name = os.path.splitext(os.path.basename(fname))[0]
		if name in db_conf['tbl_gold1']:
			extraction_method = 'x'
			folder = dir_data
		elif name in db_conf['tbl_gold2']:
			extraction_method = 'x'
			folder = dir_study
		else:
			extraction_method = 'e'
			folder = dir_data + [tbl for tbl in db_conf['tbl_gold1'] if name.startswith(tbl)][0]
		if subprocess.call(['7z', extraction_method, fname, '-bso0', '-aos', '-o'+folder]) != 0:
			ret = False
# ---------------------------------------------------------
# Move zipped file to PROCESSED directory
# ---------------------------------------------------------
		else:
			file_processed = dir_downloaded + 'processed\\' + os.path.basename(fname)
			os.rename(fname, file_processed)
	except:
		ret = False
		err = sys.exc_info()
		print("Function = {0}, Error = {1}, {2}".format("unzip_file", err[0], err[1]))
	return(ret)	

# ---------------------------------------------------------
def execute_unzip_parallel(dir_study, dir_downloaded, dir_data, debug = True):
# The zipped files are unzipped in parallel
# ---------------------------------------------------------
	ret = True

	try:
		time1 = time.time()
		msg = 'Starting parallel unzip at ' + time1.strftime("%H:%M:%S") + ' ... \n'
		log.log_message(msg)
		file_list = sorted(glob.iglob(dir_downloaded + '*.7z'))
		with ProcessPoolExecutor(len(file_list)) as executor:
			futures = [executor.submit(unzip_file, fname.lower(), dir_study, dir_downloaded, dir_data, debug) for fname in file_list]
# Retrieve the results in completion order
			for future in as_completed(futures):
				if future.result() == False:
					ret = False
					msg = 'Parallel execution stopped with error at ' + datetime.now().strftime("%d/%m/%Y, %H:%M:%S")
					break
		if ret == True:
			msg = '\n[' + datetime.now().strftime("%d/%m/%Y, %H:%M:%S") + '] Parallel execution time: '
			msg += calc_time(time.time() - time1) + "\n"
		log.log_message(msg)
	except:
		ret = False
		err = sys.exc_info()
		print("Function = {0}, Error = {1}, {2}".format("execute_unzip_parallel", err[0], err[1]))
	return(ret)	

# ---------------------------------------------------------
def load_folders(schema, folder):
	"Load files from folders into tables"
# ---------------------------------------------------------
	ret = True
	
	try:
		print("load_folders 1")
		data_provider = db_conf['data_provider']
		if data_provider == 'cprd':
			file_list = sorted(glob.iglob(folder + '\\*.txt'))
		elif data_provider == 'iqvia':
			file_list = sorted(glob.iglob(folder + '\\*.csv')) + sorted(glob.iglob(folder + '\\*.out'))
# ---------------------------------------------------------
# If list is not empty
# ---------------------------------------------------------
		if file_list:
# ---------------------------------------------------------
# Connect to db
# ---------------------------------------------------------
			cnx = sql.connect(
				user=db_conf['username'],
				password=db_conf['password'],
				database=db_conf['database']
			)
			cnx.autocommit = True
			cursor1 = cnx.cursor()
			cursor1.execute('SET datestyle TO \'' + db_conf['datestyle'] + '\'')
			cursor1.execute('SET search_path TO ' + schema)
# ---------------------------------------------------------
			time1 = time.time()
# ---------------------------------------------------------
# Create PROCESSED directory if does not exist	
# ---------------------------------------------------------
			dir_processed = folder + db_conf['dir_processed']
			if not os.path.exists(dir_processed):
				os.makedirs(dir_processed)
			pos = folder.rfind('\\')
			tbl_name = folder[pos+1:].lower()
# ---------------------------------------------------------
			for fname in file_list:
				print("File = {0}".format(fname))
# ---------------------------------------------------------
# Load - Delimiter is ASCII Character ò = E'\242' = E'\xF2'		, encoding = 'cp437'		.replace('ï¼', '-')
# ---------------------------------------------------------
				stream = StringIO()
				if data_provider == 'cprd':
#					stream.write(open(fname, errors = 'ignore').read())
					stream.write(open(fname, errors = 'ignore').read().replace('\\', ''))
				elif data_provider == 'iqvia':
					stream.write(open(fname, errors = 'backslashreplace').read().replace('ò', '	').replace('ï¼', '-').replace('\\x8d', '').replace('\\x81', '').replace('\\x8f', '').replace('\\x90', '').replace('\\x9d', '').replace('\\xd9', ''))
				stream.seek(0)
				stream.readline()	#To avoid headers
				cursor1.copy_from(stream, tbl_name, sep = '	', null = '')
# ---------------------------------------------------------
# Move loaded file to PROCESSED directory
# ---------------------------------------------------------
				file_processed = dir_processed + os.path.basename(fname)
				os.rename(fname, file_processed)
			cursor1.close()
			cnx.close()
			processing_time = "Files loaded in {0}".format(calc_time(time.time() - time1))
			print(processing_time)
# ---------------------------------------------------------
		print("load_folders 2")
	except:
		ret = False
		err = sys.exc_info()
		print("Function = {0}, Error = {1}, {2}".format("load_folders", err[0], err[1]))
	return(ret)

# ---------------------------------------------------------
def load_folders_parallel(schema, folder_list):
	"Load files into tables"
# ---------------------------------------------------------
	ret = True
	
	try:
		print("load_folders_parallel 1")
		time1 = time.time()
# ---------------------------------------------------------
# Load files in parallel (all tables), sequentially within each table
# ---------------------------------------------------------
		with ProcessPoolExecutor(int(db_conf['max_workers'])) as executor:
			futures = [executor.submit(load_folders, schema, folder) for folder in folder_list]
			for future in as_completed(futures):
				if future.result() == False:
					ret = False
					log.log_message('load_folders_parallel stopped with errors at ' + datetime.now().strftime("%d/%m/%Y, %H:%M:%S"))
					break
		if ret == True:
			msg = '\n[' + datetime.now().strftime("%d/%m/%Y, %H:%M:%S") + '] load_folders_parallel execution time: '
			msg += calc_time(time.time() - time1) + "\n"
			log.log_message(msg)
# ---------------------------------------------------------
		print("load_folders_parallel 2")
	except:
		ret = False
		err = sys.exc_info()
		print("Function = {0}, Error = {1}, {2}".format("load_folders_parallel", err[0], err[1]))
	return(ret)

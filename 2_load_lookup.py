import os
import sys
import time
import glob
import csv
import psycopg2 as sql
from datetime import datetime
from importlib.machinery import SourceFileLoader

mapping_util = SourceFileLoader('mapping_util', os.path.dirname(os.path.realpath(__file__)) + '/mapping_util.py').load_module()

# ---------------------------------------------------------
def populate_tbl_lookup_gold(dir_files):
	"Populate lookuptype and lookup table from 3-character files"
# ---------------------------------------------------------
	ret 			= True
	row				= []
	cursor1 		= None
	
	try:
# ---------------------------------------------------------
# Connect to db
# ---------------------------------------------------------
		cnx = sql.connect(
			user=db_conf['username'],
			password=db_conf['password'],
			database=db_conf['database'],
			port=db_conf['port']
		)
		cnx.autocommit = True
		cursor1 = cnx.cursor()
# ---------------------------------------------------------
# Create PROCESSED directory if does not exist	
# ---------------------------------------------------------
		dir_processed = dir_files + db_conf['dir_processed']
		if not os.path.exists(dir_processed):
			os.makedirs(dir_processed)
		
		sql_insert_lookuptype = "INSERT INTO source.lookuptype (lookup_type_id, name, description) VALUES (%(lookup_type_id)s, %(name)s, %(description)s)"
		sql_insert_lookup = "INSERT INTO source.lookup (lookup_type_id, code, text) VALUES (%(lookup_type_id)s, %(code)s, %(text)s)"

		lookup_type_id = 1
		file_list = dir_files + "\\*.txt"
		for fname in sorted(glob.iglob(file_list)): 
#			print("fname = " + fname)
			fname_short = os.path.splitext(os.path.basename(fname))[0]
			data_lookuptype = {
				'lookup_type_id': lookup_type_id,
				'name': fname_short,
				'description': fname_short,
			}
			cursor1.execute(sql_insert_lookuptype, data_lookuptype)
			with open(fname,encoding='latin1') as file:
				rows_processed = 0
				csv_file = csv.reader(file, delimiter='\t')
				next(csv_file, None);	#Skip header
				for row in csv_file:
					if row == []:	#For some files, last row does not end in CR LF, but by CR CR LF
						break;
					data_lookup = {
						'lookup_type_id': lookup_type_id,
						'code': int(row[0]),
						'text': row[1],
					}
					cursor1.execute(sql_insert_lookup, data_lookup)
					rows_processed += 1
					print("File name = {0}, Records = {1}".format(fname, rows_processed))
# Move file to PROCESSED directory
			file_processed = dir_processed + os.path.basename(fname)
			os.rename(fname, file_processed)
			lookup_type_id += 1
		cursor1.close()
		cursor1 = None
# ---------------------------------------------------------
# Release db
# ---------------------------------------------------------
		cnx.close()
	except:
		ret = False
		err = sys.exc_info()
		print("Function = {0}, Table name = {1}, Error = {2}, {3}".format("populate_tbl_lookup_gold", "lookup", err[0], err[1]))
		if cursor1 != None:
			cursor1.close()
	return(ret)

# ---------------------------------------------------------
# MAIN PROGRAM
# ---------------------------------------------------------
def main():
	ret = True
	global db_conf

	try:
		(ret, dir_study, db_conf, debug) = mapping_util.get_parameters()
		if ret == True and dir_study != '':
			data_provider = db_conf['data_provider']
			database_type = db_conf['database_type']
			database_name = database_type.upper()
			schema = db_conf['source_schema']
			
			if database_type[:3].upper() == 'HES':
				database_name = 'HES'
				database_type = 'linkage'
				schema = db_conf['linkage_schema']
			elif database_type[:5].upper() == 'NCRAS':
				database_name = 'NCRAS'
				database_type = 'linkage'
				schema = db_conf['linkage_schema']
			dir_sql = os.getcwd() + '\\sql_scripts\\'
			dir_sql_processed = os.getcwd() + '\\sql_scripts' + db_conf['dir_processed']
			if not os.path.exists(dir_sql_processed):
				os.makedirs(dir_sql_processed)
			dir_lookup = db_conf['dir_lookup'] + "\\"
			dir_lookup_processed = db_conf['dir_lookup'] + db_conf['dir_processed']
#			if not os.path.exists(dir_lookup_processed):
#				os.makedirs(dir_lookup_processed)
			fname = dir_sql + '2a_' + database_type + '_lookup_drop.sql'
			if os.path.isfile(fname) == False:
				print('No lookup files to process for ' + database_name + ' dataset')
			else:
# ---------------------------------------------------------
# Drop LOOKUP tables - Parallel execution of queries in the file - Ask the user for DROP confirmation
# ---------------------------------------------------------
				qa = input('Are you sure you want to DROP all the ' + database_name + ' LOOKUP tables (y/n):') 
				while qa.lower() not in ['y', 'n', 'yes', 'no']:
					qa = input('I did not understand that. Are you sure you want to DROP all the ' + database_name + ' LOOKUP tables (y/n):') 
				if qa.lower() in ['y', 'yes']:
					fname = dir_sql + '2a_' + database_type + '_lookup_drop.sql'
					print('Calling ' + fname + ' ...')
					ret = mapping_util.execute_sql_file_parallel(db_conf, fname, False, False)
# ---------------------------------------------------------
# Create LOOKUP tables - Parallel execution of queries in the file - Ask the user for CREATE/LOAD confirmation
# ---------------------------------------------------------
				if ret == True:
					qa = input('Are you sure you want to CREATE/LOAD all the ' + database_name + ' LOOKUP tables (y/n):') 
					while qa.lower() not in ['y', 'n', 'yes', 'no']:
						qa = input('I did not understand that. Are you sure you want to CREATE/LOAD all the ' + database_name + ' LOOKUP tables (y/n):') 
					if qa.lower() in ['y', 'yes']:
						fname = dir_sql + '2b_' + database_type + '_lookup_create.sql'
						print('Calling ' + fname + ' ...')
						ret = mapping_util.execute_multiple_queries(db_conf, fname, None, None, True, debug, False)
# ---------------------------------------------------------
# Load normal LOOKUP tables - Parallel execution
# ---------------------------------------------------------
						if ret == True:
							tbl_lookup = 'tbl_' + database_type + '_lookup'
							tbl_lookup_list =  [tbl for tbl in db_conf[tbl_lookup]]
							if 'ukb' == data_provider:
								file_lookup_list = [[dir_lookup + '*' + tbl.replace("lookup", "coding") + '*.txt'] for tbl in tbl_lookup_list]
							else:
								file_lookup_list = [[dir_lookup + '*' + tbl + '*.txt'] for tbl in tbl_lookup_list]
							print(file_lookup_list)
							if not os.path.exists(dir_lookup_processed):
								os.makedirs(dir_lookup_processed)
							ret = mapping_util.load_files_parallel(db_conf, schema, tbl_lookup_list, file_lookup_list, dir_lookup_processed)
# ---------------------------------------------------------
# Load special LOOKUP tables - Sequential execution
# ---------------------------------------------------------
							if ret == True and database_type == 'gold':
								dir_special = dir_lookup + "TXTFILES"
								if os.path.isdir(dir_special):
									ret = populate_tbl_lookup_gold(dir_special)
							if ret == True:
								print('Finished loading LOOKUP tables.')
# ---------------------------------------------------------
# Create LOOKUP PK, indexes - Sequential execution (could be parallel, but the time saving would be irrilevant)
# ---------------------------------------------------------
				if ret == True:
					qa = input('Are you sure you want to CREATE PK/IDXs for all the LOOKUP tables (y/n):') 
					while qa.lower() not in ['y', 'n', 'yes', 'no']:
						qa = input('I did not understand that. Are you sure you want to CREATE PK/IDXs for all the LOOKUP tables (y/n):') 
					if qa.lower() in ['y', 'yes']:
						fname = dir_sql + '2c_' + database_type + '_lookup_pk_idx.sql'
						ret = mapping_util.execute_multiple_queries(db_conf, fname, None, None, True, True)
						if ret == True:
							print('Finished applying indexes LOOKUP tables')	
# ---------------------------------------------------------
# Create daysupply_modes and daysupply_decodes - Sequential execution 
# ---------------------------------------------------------
				if ret == True and database_type == 'gold':
					qa = input('Are you sure you want to CREATE daysupply_modes and daysupply_decodes tables (y/n):')
					while qa.lower() not in ['y', 'n', 'yes', 'no']:
						qa = input('I did not understand that. Are you sure you want to CREATE daysupply_modes and daysupply_decodes tables (y/n):')
					if qa.lower() in ['y', 'yes']:
						fname = dir_sql + '2d_' + database_type + '_daysupply_create.sql'
						print(fname + ' ...')
						ret = mapping_util.execute_multiple_queries(db_conf, fname, None, None, True, True)
						if ret == True:
							print('Finished creation of daysupply_modes and daysupply_decodes tables.')
# ---------------------------------------------------------
# Move CODE to the processed directory?
# ---------------------------------------------------------
				if ret == True:
					qa = input('Are you sure you want to MOVE all the lookup CODE in the "processed" folder (y/n):') 
					while qa.lower() not in ['y', 'n', 'yes', 'no']:
						qa = input('I did not understand that. Are you sure you want to MOVE all the lookup CODE in the "processed" folder (y/n):') 
					if qa.lower() in ['y', 'yes']:
						for f in glob.iglob(dir_sql + '2*.sql'):
							file_processed = dir_sql_processed + os.path.basename(f)
							os.rename(f, file_processed)
						print('Finished MOVING code files')	
	except:
		print(str(sys.exc_info()[1]))

# ---------------------------------------------------------
# Protect entry point for concurrent processing
# ---------------------------------------------------------
if __name__ == "__main__":
	main()

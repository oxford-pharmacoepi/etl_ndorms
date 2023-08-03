import os
import sys
import time
import glob
from datetime import datetime
import psycopg2 as sql
from importlib.machinery import SourceFileLoader
from importlib import import_module

db_conf	= import_module('__postgres_db_conf',os.getcwd() + '\\__postgres_db_conf.py').db_conf
log = import_module('write_log', os.getcwd() + '\\write_log.py').Log('1_load_source_data')
mapping_util = SourceFileLoader('mapping_util', os.path.dirname(os.path.realpath(__file__)) + '/mapping_util.py').load_module()

# ---------------------------------------------------------
def is_curation_needed(tbl_patient, tbl_observation):
	"Check if curation is necessary"
# ---------------------------------------------------------
	ret 		= True
	curation 	= False
	
	try:
		cnx = sql.connect(
			user = db_conf['username'],
			password = db_conf['password'],
			database = db_conf['database']
		)
		cursor1 = cnx.cursor()
		query1 = "SELECT 1 FROM " + tbl_patient + " WHERE acceptable = 0 OR gender in (0,3,4) OR gender is null OR yob < 1875 OR regstartdate is null LIMIT 1"
		cursor1.execute(query1);
		found = cursor1.fetchone()
		if found != None:
			curation = True
		else:
			query1 = "SELECT 1 FROM " + tbl_observation + " WHERE obsdate is null"
		cursor1.execute(query1);
		found = cursor1.fetchone()
		if found != None:
			curation = True
		cursor1.close()
		cnx.close()	
	except:
		ret = False
		err = sys.exc_info()
		print("Function = {0}, Error = {1}, {2}".format("is_curation_needed", err[0], err[1]))
	return(ret, curation)

# ---------------------------------------------------------
# MAIN PROGRAM
# ---------------------------------------------------------
def main():
	ret = True

	try:
		time0 = time.time()
		database_type = db_conf['database_type']
		source_schema = db_conf['source_schema']
		dir_source_files = db_conf['dir_study'] + 'data\\'
		tbl_db = 'tbl_' + database_type
		tbl_db_list =  [source_schema + "." + tbl for tbl in db_conf[tbl_db]]
		dir_sql = os.getcwd() + '\\sql_scripts\\'
		dir_sql_processed = os.getcwd() + '\\sql_scripts' + db_conf['dir_processed']
#		dir_voc = db_conf['dir_voc'] + "\\"		#study_directory + "vocabulary\\"
#		dir_voc_processed = db_conf['dir_voc'] + db_conf['dir_processed']
# ---------------------------------------------------------
# Ask the user for DROP confirmation
# ---------------------------------------------------------
		drop_tbls = input('Are you sure you want to DROP all the ' + database_type.upper() + ' tables (y/n):') 
		while drop_tbls.lower() not in ['y', 'n', 'yes', 'no']:
			drop_tbls = input('I did not understand that. Are you sure you want to DROP all the ' + database_type.upper() + ' tables (y/n):') 
		if drop_tbls.lower() in ['y', 'yes']:
			fname = dir_sql + '1a_' + database_type + '_drop.sql'
			log.log_message('Calling ' + fname + ' ...')
			ret = mapping_util.execute_sql_file_parallel(fname, False)
		if ret == True:
# ---------------------------------------------------------
# Ask the user for LOAD confirmation
# ---------------------------------------------------------
			load_tbls = input('Are you sure you want to CREATE/LOAD all the ' + database_type.upper() + ' tables (y/n):') 
			while load_tbls.lower() not in ['y', 'n', 'yes', 'no']:
				load_tbls = input('I did not understand that. Are you sure you want to CREATE/LOAD all the ' + database_type.upper() + ' tables (y/n):') 
			if load_tbls.lower() in ['y', 'yes']:
# ---------------------------------------------------------
# Create source tables
# ---------------------------------------------------------
				time1 = time.time()
				fname = dir_sql + '1b_' + database_type + '_create.sql'
				log.log_message('Calling ' + fname + ' ...')
				ret = mapping_util.execute_sql_file_parallel(fname, False)
# ---------------------------------------------------------
# Load source data
# ---------------------------------------------------------
				if ret == True:
					dir_list_folders = [dir_source_files + tbl for tbl in db_conf[tbl_db]]
					ret = mapping_util.load_folders_parallel(source_schema, dir_list_folders)
					if ret == True:
#						log.log_message('Finished loading ' + database_type.upper() + ' source data.')
						task_finished = "Finished loading " + database_type.upper() + " source data in {0}".format(mapping_util.calc_time(time.time() - time1))
						log.log_message(task_finished)
# ---------------------------------------------------------
# Ask the user for PK/IDX creation confirmation
# ---------------------------------------------------------
		if ret == True:
			load_tbls = input('Are you sure you want to CREATE PK/IDXs on all the ' + database_type.upper() + ' tables (y/n):') 
			while load_tbls.lower() not in ['y', 'n', 'yes', 'no']:
				load_tbls = input('Are you sure you want to CREATE PK/IDXs on all the ' + database_type.upper() + ' tables (y/n):') 
			if load_tbls.lower() in ['y', 'yes']:
# ---------------------------------------------------------
# Build PKs & IDXs
# ---------------------------------------------------------
				time1 = time.time()
				log.log_message('Build PKs and IDXs ...')
				sql_file_list = sorted(glob.iglob(dir_sql + '1c_' + database_type + '_pk_idx_*.sql'))
				ret = mapping_util.execute_sql_files_parallel(sql_file_list, True)
				if ret == True:
					log.log_message('Finished adding ' + database_type.upper() + ' PKs/indexes')
# ---------------------------------------------------------
# Check source data if patient table has patids to remove
# ---------------------------------------------------------
					index_patient = db_conf[tbl_db].index('patient')
					idx_observation = db_conf[tbl_db].index('observation')
					(ret, curation) = is_curation_needed(tbl_db_list[index_patient], tbl_db_list[idx_observation])
					if curation == True:
						fname = dir_sql + '1d_' + database_type + '_curation.sql'
						log.log_message('Executing ' + fname + ' ...')
						ret = mapping_util.execute_multiple_queries(fname, None, None, True, True)
						if ret == True:
							task_finished = "Finished curation on  " + database_type.upper() + " data in {0}".format(mapping_util.calc_time(time.time() - time1))
							log.log_message(task_finished)
#							log.log_message('Finished curation on ' + database_type.upper() + ' data\n')	
# ---------------------------------------------------------
# Ask the user for RECORD COUNTS confirmation
# ---------------------------------------------------------
		if ret == True:
			load_tbls = input('Are you sure you want to COUNT the records for all the ' + database_type.upper() + ' tables (y/n):') 
			while load_tbls.lower() not in ['y', 'n', 'yes', 'no']:
				load_tbls = input('Are you sure you want to COUNT the records for all the ' + database_type.upper() + ' tables (y/n):') 
			if load_tbls.lower() in ['y', 'yes']:
				time1 = time.time()
				source_nok_schema = db_conf['source_nok_schema']
#				tbl_list_count = tbl_db_list + [source_nok_schema + "." + tbl for tbl in db_conf[tbl_db] if tbl not in ('practice', 'staff')]
				tbl_list_count = tbl_db_list + [source_nok_schema + "." + tbl for tbl in db_conf[tbl_db]]
				ret = mapping_util.get_table_count_parallel(tbl_list_count, source_schema + '._records')
				if ret == True:
#					log.log_message('Finished counting on ' + database_type.upper() + ' data\n')	
					task_finished = "Finished counting on  " + database_type.upper() + " data in {0}".format(mapping_util.calc_time(time.time() - time1))
					log.log_message(task_finished)
# ---------------------------------------------------------
# Move CODE to the processed directory?
# ---------------------------------------------------------
		if ret == True:
			load_tbls = input('Are you sure you want to MOVE all the source CODE in the "processed" folder (y/n):') 
			while load_tbls.lower() not in ['y', 'n', 'yes', 'no']:
				load_tbls = input('I did not understand that. Are you sure you want to MOVE all the source CODE in the "processed" folder (y/n):') 
			if load_tbls.lower() in ['y', 'yes']:
				for f in glob.iglob(dir_sql + '1*.sql'):
					file_processed = dir_sql_processed + os.path.basename(f)
					os.rename(f, file_processed)
				log.log_message('Finished MOVING code files')	
# ---------------------------------------------------------
# Report total time
# ---------------------------------------------------------
		if ret == True:
			process_finished = "{0} completed in {1}".format(os.path.basename(__file__), mapping_util.calc_time(time.time() - time0))
			log.log_message(process_finished)
	except:
		log.log_message(str(sys.exc_info()[1]))

# ---------------------------------------------------------
# Protect entry point
# ---------------------------------------------------------
if __name__ == "__main__":
	main()

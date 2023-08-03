import os
import sys
import time
import glob
import psycopg2 as sql
from datetime import datetime
from importlib import import_module
from importlib.machinery import SourceFileLoader

db_conf = import_module('__postgres_db_conf', os.getcwd() + '\\__postgres_db_conf.py').db_conf
log = import_module('write_log', os.getcwd() + '\\write_log.py').Log('2_load_lookup')
mapping_util = SourceFileLoader('mapping_util', os.path.dirname(os.path.realpath(__file__)) + '/mapping_util.py').load_module()

# ---------------------------------------------------------
# MAIN PROGRAM
# ---------------------------------------------------------
def main():
	ret = True

	try:
		time0 = time.time()
		database_type = db_conf['database_type']
		source_schema = db_conf['source_schema']
		dir_sql = os.getcwd() + '\\sql_scripts\\'
		dir_sql_processed = os.getcwd() + '\\sql_scripts' + db_conf['dir_processed']
		dir_lookup = db_conf['dir_lookup'] + "\\"
		dir_lookup_processed = db_conf['dir_lookup'] + db_conf['dir_processed']
# ---------------------------------------------------------
# Drop LOOKUP tables - Parallel execution of queries in the file - Ask the user for DROP confirmation
# ---------------------------------------------------------
		drop_tbls = input('Are you sure you want to DROP all the ' + database_type.upper() + ' LOOKUP tables (y/n):') 
		while drop_tbls.lower() not in ['y', 'n', 'yes', 'no']:
			drop_tbls = input('I did not understand that. Are you sure you want to DROP all the ' + database_type.upper() + ' LOOKUP tables (y/n):') 
		if drop_tbls.lower() in ['y', 'yes']:
			fname = dir_sql + '2a_' + database_type + '_lookup_drop.sql'
			log.log_message('Calling ' + fname + ' ...')
			ret = mapping_util.execute_sql_file_parallel(fname, False)
# ---------------------------------------------------------
# Create LOOKUP tables - Parallel execution of queries in the file - Ask the user for CREATE/LOAD confirmation
# ---------------------------------------------------------
		if ret == True:
			load_tbls = input('Are you sure you want to CREATE/LOAD all the ' + database_type.upper() + ' LOOKUP tables (y/n):') 
			while load_tbls.lower() not in ['y', 'n', 'yes', 'no']:
				load_tbls = input('I did not understand that. Are you sure you want to CREATE/LOAD all the ' + database_type.upper() + ' LOOKUP tables (y/n):') 
			if load_tbls.lower() in ['y', 'yes']:
				time1 = time.time()
				fname = dir_sql + '2b_' + database_type + '_lookup_create.sql'
				log.log_message('Calling ' + fname + ' ...')
				ret = mapping_util.execute_sql_file_parallel(fname, False)
# ---------------------------------------------------------
# Load LOOKUP tables - Parallel execution
# ---------------------------------------------------------
				if ret == True:
					tbl_lookup = 'tbl_' + database_type + '_lookup'
					tbl_lookup_list =  [tbl for tbl in db_conf[tbl_lookup]]
					file_lookup_list = [[dir_lookup + '*' + tbl + '.txt'] for tbl in tbl_lookup_list]
					if not os.path.exists(dir_lookup_processed):
						os.makedirs(dir_lookup_processed)
					ret = mapping_util.load_files_parallel(source_schema, tbl_lookup_list, file_lookup_list, dir_lookup_processed)
					if ret == True:
						task_finished = "Finished loading LOOKUP tables in {0}".format(mapping_util.calc_time(time.time() - time1))
						log.log_message(task_finished)
# ---------------------------------------------------------
# Create LOOKUP PK, indexes - Parallel execution
# ---------------------------------------------------------
		if ret == True:
			load_tbls = input('Are you sure you want to CREATE PK/IDXs for all the LOOKUP tables (y/n):') 
			while load_tbls.lower() not in ['y', 'n', 'yes', 'no']:
				load_tbls = input('I did not understand that. Are you sure you want to CREATE PK/IDXs for all the LOOKUP tables (y/n):') 
			if load_tbls.lower() in ['y', 'yes']:
				time1 = time.time()
				fname = dir_sql + '2c_' + database_type + '_lookup_pk_idx.sql'
				log.log_message(fname + ' ...')
				ret = mapping_util.execute_multiple_queries(fname, None, None, True, True)
				if ret == True:
					task_finished = "Finished applying indexes LOOKUP tables in {0}".format(mapping_util.calc_time(time.time() - time1))
					log.log_message(task_finished)
# ---------------------------------------------------------
# Move CODE to the processed directory?
# ---------------------------------------------------------
		if ret == True:
			load_tbls = input('Are you sure you want to MOVE all the lookup CODE in the "processed" folder (y/n):') 
			while load_tbls.lower() not in ['y', 'n', 'yes', 'no']:
				load_tbls = input('I did not understand that. Are you sure you want to MOVE all the lookup CODE in the "processed" folder (y/n):') 
			if load_tbls.lower() in ['y', 'yes']:
				for f in glob.iglob(dir_sql + '2*.sql'):
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
# Protect entry point for concurrent processing
# ---------------------------------------------------------
if __name__ == "__main__":
	main()

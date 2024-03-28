import os
import sys
import time
import glob
from datetime import datetime
import psycopg2 as sql
from importlib.machinery import SourceFileLoader

mapping_util = SourceFileLoader('mapping_util', os.path.dirname(os.path.realpath(__file__)) + '/mapping_util.py').load_module()

# ---------------------------------------------------------
# MAIN PROGRAM
# ---------------------------------------------------------
def main():
	ret = True
	global db_conf

	try:
		(ret, dir_study, db_conf, debug) = mapping_util.get_parameters()
		if ret == True and dir_study != '':
			time0 = time.time()
			database_type = db_conf['database_type']
			source_schema = db_conf['source_schema']
			dir_source_files = dir_study + '\\data\\'
			tbl_db = 'tbl_linked'
			tbl_db_list =  [source_schema + "." + tbl for tbl in db_conf[tbl_db]]
			dir_sql = os.getcwd() + '\\sql_scripts\\'
			dir_sql_processed = os.getcwd() + '\\sql_scripts' + db_conf['dir_processed']
			if not os.path.exists(dir_sql_processed):
				os.makedirs(dir_sql_processed)
# ---------------------------------------------------------
# If database does not exist, create database
# ---------------------------------------------------------
			(ret, exist) = mapping_util.does_db_exist(db_conf)
			if exist == False:
				ret = mapping_util.create_db(db_conf)
			if ret == True:
# ---------------------------------------------------------
# Create the schemas
# ---------------------------------------------------------
				fname = dir_sql + '10__schema_create.sql'
				print('Calling ' + fname + ' ...')
				ret = mapping_util.execute_sql_file_parallel(db_conf, fname, False)
			if ret == True:
# ---------------------------------------------------------
# Ask the user for DROP confirmation
# ---------------------------------------------------------
				qa = input('Are you sure you want to DROP all the linked data:' + database_type + ' tables (y/n):') 
				while qa.lower() not in ['y', 'n', 'yes', 'no']:
					qa = input('I did not understand that. Are you sure you want to DROP all the linked data:' + database_type + ' tables (y/n):') 
				if qa.lower() in ['y', 'yes']:
					fname = dir_sql + '10a_' + database_type + '_drop.sql'
					print('Calling ' + fname + ' ...')
					ret = mapping_util.execute_sql_file_parallel(db_conf, fname, False)
			if ret == True:
# ---------------------------------------------------------
# Ask the user for LOAD confirmation
# ---------------------------------------------------------
				qa = input('Are you sure you want to CREATE/LOAD all the linked data:' + database_type + ' tables (y/n):') 
				while qa.lower() not in ['y', 'n', 'yes', 'no']:
					qa = input('I did not understand that. Are you sure you want to CREATE/LOAD all the linked data:' + database_type + ' tables (y/n):') 
				if qa.lower() in ['y', 'yes']:
# ---------------------------------------------------------
# Create source tables
# ---------------------------------------------------------
					time1 = time.time()
					fname = dir_sql + '10b_' + database_type + '_create.sql'
					print('Calling ' + fname + ' ...')
					ret = mapping_util.execute_sql_file_parallel(db_conf, fname, False)
# ---------------------------------------------------------
# Load source data
# ---------------------------------------------------------
					if ret == True:
						dir_list_folders = sorted(glob.iglob(dir_source_files + '*'))
						dir_list_folders = [dir_source_files + tbl for tbl in db_conf['tbl_linked']]
						print(dir_list_folders)
						ret = mapping_util.load_folders_parallel(db_conf, source_schema, dir_list_folders)
						if ret == True:
							task_finished = "Finished loading " + database_type.upper() + " source data in {0}".format(mapping_util.calc_time(time.time() - time1))
							print(task_finished)
# ---------------------------------------------------------
# Ask the user for PK/IDX creation confirmation
# ---------------------------------------------------------
			if ret == True:
				qa = input('Are you sure you want to CREATE PK/IDXs on all the linked data:' + database_type + ' tables (y/n):') 
				while qa.lower() not in ['y', 'n', 'yes', 'no']:
					qa = input('Are you sure you want to CREATE PK/IDXs on all the linked data:' + database_type + ' tables (y/n):') 
				if qa.lower() in ['y', 'yes']:
# ---------------------------------------------------------
# Build PKs & IDXs
# ---------------------------------------------------------
					time1 = time.time()
					print('Build PKs and IDXs ...')
					sql_file_list = sorted(glob.iglob(dir_sql + '10c_' + database_type + '_pk_idx_*.sql'))
					ret = mapping_util.execute_sql_files_parallel(db_conf, sql_file_list, True)
					if ret == True:
						task_finished = 'Finished adding PKs/indexes to ' + database_type.upper() + ' in {0}'.format(mapping_util.calc_time(time.time() - time1))
						print(task_finished)
# ---------------------------------------------------------
# Check for curation
# ---------------------------------------------------------
			if ret == True:
				qa = input('Are you sure you want to CHECK/CURATE linked data (y/n):') 
				while qa.lower() not in ['y', 'n', 'yes', 'no']:
					qa = input('Are you sure you want to CHECK/CURATE ' + database_type.upper() + ' (y/n):') 
				if qa.lower() in ['y', 'yes']:
					time1 = time.time()
					fname = dir_sql + '10d_' + database_type + '_curation.sql'
					print('Executing ' + fname + ' ...')
					ret = mapping_util.execute_multiple_queries(db_conf, fname, None, None, True, True)
					if ret == True:
						task_finished = "Finished curation on  " + database_type.upper() + " data in {0}".format(mapping_util.calc_time(time.time() - time1))
						print(task_finished)
# ---------------------------------------------------------
# Ask the user for RECORD COUNTS confirmation
# ---------------------------------------------------------
			if ret == True:
				qa = input('Are you sure you want to COUNT the records for all the ' + database_type.upper() + ' tables (y/n):') 
				while qa.lower() not in ['y', 'n', 'yes', 'no']:
					qa = input('Are you sure you want to COUNT the records for all the ' + database_type.upper() + ' tables (y/n):') 
				if qa.lower() in ['y', 'yes']:
					time1 = time.time()
					fname = dir_sql + '1e_source_records_create.sql'
					print('Calling ' + fname + ' ...')
					ret = mapping_util.execute_multiple_queries(db_conf, fname)			
					if ret == True:
						source_nok_schema = db_conf['source_nok_schema']
						tbl_list_count = tbl_db_list + [source_nok_schema + "." + tbl for tbl in db_conf[tbl_db]]
						ret = mapping_util.get_table_count_parallel(db_conf, tbl_list_count, source_schema + '._records')
						if ret == True:
							task_finished = "Finished counting on  " + database_type.upper() + " data in {0}".format(mapping_util.calc_time(time.time() - time1))
							print(task_finished)
# ---------------------------------------------------------
# Move CODE to the processed directory?
# ---------------------------------------------------------
			if ret == True:
				qa = input('Are you sure you want to MOVE all the source CODE in the "processed" folder (y/n):') 
				while qa.lower() not in ['y', 'n', 'yes', 'no']:
					qa = input('I did not understand that. Are you sure you want to MOVE all the source CODE in the "processed" folder (y/n):') 
				if qa.lower() in ['y', 'yes']:
					for f in glob.iglob(dir_sql + '10*.sql'):
						file_processed = dir_sql_processed + os.path.basename(f)
						os.rename(f, file_processed)
					print('Finished MOVING code files')	
# ---------------------------------------------------------
# Report total time
# ---------------------------------------------------------
			if ret == True:
				process_finished = "{0} completed in {1}".format(os.path.basename(__file__), mapping_util.calc_time(time.time() - time0))
				print(process_finished)
	except:
		print(str(sys.exc_info()[1]))

# ---------------------------------------------------------
# Protect entry point
# ---------------------------------------------------------
if __name__ == "__main__":
	main()

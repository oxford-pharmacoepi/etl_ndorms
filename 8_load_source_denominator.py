import os
import sys
import time
import glob
from datetime import datetime
import psycopg2 as sql
from importlib.machinery import SourceFileLoader
from importlib import import_module

db_conf	= import_module('__postgres_db_conf',os.getcwd() + '\\__postgres_db_conf.py').db_conf
log = import_module('write_log', os.getcwd() + '\\write_log.py').Log('8_load_source_denominator')
mapping_util = SourceFileLoader('mapping_util', os.path.dirname(os.path.realpath(__file__)) + '/mapping_util.py').load_module()

# ---------------------------------------------------------
# MAIN PROGRAM
# ---------------------------------------------------------
def main():
	ret = True

	try:
		database_type = db_conf['database_type']
		source_schema = db_conf['source_schema']
		tbl_db = 'tbl_' + database_type
		tbl_db_list =  [source_schema + "." + tbl for tbl in db_conf[tbl_db]]
		dir_denom = db_conf['dir_study'] + 'denominator\\'
		dir_denom_processed = dir_denom + db_conf['dir_processed']
		dir_sql = os.getcwd() + '\\sql_scripts\\'
		dir_sql_processed = os.getcwd() + '\\sql_scripts' + db_conf['dir_processed']
# ---------------------------------------------------------
# Ask the user for DROP confirmation
# ---------------------------------------------------------
		drop_tbls = input('Are you sure you want to DROP the ' + database_type.upper() + ' denominators tables (y/n):') 
		while drop_tbls.lower() not in ['y', 'n', 'yes', 'no']:
			drop_tbls = input('I did not understand that. Are you sure you want to DROP the ' + database_type.upper() + ' denominators tables (y/n):') 
		if drop_tbls.lower() in ['y', 'yes']:
			fname = dir_sql + '7a_' + database_type + '_denom_drop.sql'
			log.log_message('Calling ' + fname + ' ...')
			ret = mapping_util.execute_sql_file_parallel(fname, False)
		if ret == True:
# ---------------------------------------------------------
# Ask the user for LOAD confirmation
# ---------------------------------------------------------
			load_tbls = input('Are you sure you want to CREATE/LOAD the ' + database_type.upper() + ' denominators tables (y/n):') 
			while load_tbls.lower() not in ['y', 'n', 'yes', 'no']:
				load_tbls = input('I did not understand that. Are you sure you want to CREATE/LOAD all the ' + database_type.upper() + ' denominators tables (y/n):') 
			if load_tbls.lower() in ['y', 'yes']:
# ---------------------------------------------------------
# Create denominators tables
# ---------------------------------------------------------
				fname = dir_sql + '7b_' + database_type + '_denom_create.sql'
				log.log_message('Calling ' + fname + ' ...')
				ret = mapping_util.execute_sql_file_parallel(fname, False)
# ---------------------------------------------------------
# Load denominators data - Parallel execution
# ---------------------------------------------------------
				if ret == True:
					tbl_denom = 'tbl_' + database_type + '_denom'
					tbl_denom_list = [tbl for tbl in db_conf[tbl_denom]]
					file_denom_list = [[dir_denom + '*' + tbl + '.txt'] for tbl in tbl_denom_list]
					if not os.path.exists(dir_denom_processed):
						os.makedirs(dir_denom_processed)
					ret = mapping_util.load_files_parallel(source_schema, tbl_denom_list, file_denom_list, dir_denom_processed)
					if ret == True:
						log.log_message('Finished loading cdm vocabulary.')
# ---------------------------------------------------------
# Ask the user for PK/IDX creation confirmation
# ---------------------------------------------------------
		if ret == True:
			load_tbls = input('Are you sure you want to CREATE PK/IDXs on the ' + database_type.upper() + ' denominators tables (y/n):') 
			while load_tbls.lower() not in ['y', 'n', 'yes', 'no']:
				load_tbls = input('Are you sure you want to CREATE PK/IDXs on all the ' + database_type.upper() + ' denominators tables (y/n):') 
			if load_tbls.lower() in ['y', 'yes']:
# ---------------------------------------------------------
# Build PKs & IDXs
# ---------------------------------------------------------
				log.log_message('Build PKs and IDXs ...')
				sql_file_list = sorted(glob.iglob(dir_sql + '7c_' + database_type + '_denom_pk_idx_*.sql'))
				ret = mapping_util.execute_sql_files_parallel(sql_file_list, True)
				if ret == True:
					log.log_message('Finished adding ' + database_type.upper() + ' PKs/indexes')
# ---------------------------------------------------------
# Ask the user for RECORD COUNTS confirmation
# ---------------------------------------------------------
		if ret == True:
			load_tbls = input('Are you sure you want to COUNT the records for all the ' + database_type.upper() + ' tables (y/n):') 
			while load_tbls.lower() not in ['y', 'n', 'yes', 'no']:
				load_tbls = input('Are you sure you want to COUNT the records for all the ' + database_type.upper() + ' tables (y/n):') 
			if load_tbls.lower() in ['y', 'yes']:
				source_nok_schema = db_conf['source_nok_schema']
				tbl_list_count = tbl_db_list + [source_nok_schema + "." + tbl for tbl in db_conf[tbl_db] if tbl not in ('practice', 'staff')]
				ret = mapping_util.get_table_count_parallel(tbl_list_count, source_schema + '._records')
				if ret == True:
					log.log_message('Finished counting on ' + database_type.upper() + ' data\n')	
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
	except:
		log.log_message(str(sys.exc_info()[1]))

# ---------------------------------------------------------
# Protect entry point
# ---------------------------------------------------------
if __name__ == "__main__":
	main()

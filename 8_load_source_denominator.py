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

	try:
		(ret, dir_study, db_conf, debug) = mapping_util.get_parameters()
		if ret == True and dir_study != '':
			database_type = db_conf['database_type']
			source_schema = db_conf['source_schema']
			tbl_db = 'tbl_' + database_type
			tbl_db_list =  [source_schema + "." + tbl for tbl in db_conf[tbl_db]]
			dir_denom = dir_study + '\\denominators\\'
			dir_denom_processed = dir_denom + db_conf['dir_processed']
			dir_sql = os.getcwd() + '\\sql_scripts\\'
			dir_sql_processed = os.getcwd() + '\\sql_scripts' + db_conf['dir_processed']
# ---------------------------------------------------------
# Ask the user for DROP confirmation
# ---------------------------------------------------------
			qa = input('Are you sure you want to DROP the ' + database_type.upper() + ' denominators tables (y/n):') 
			while qa.lower() not in ['y', 'n', 'yes', 'no']:
				qa = input('I did not understand that. Are you sure you want to DROP the ' + database_type.upper() + ' denominators tables (y/n):') 
			if qa.lower() in ['y', 'yes']:
				fname = dir_sql + '7a_' + database_type + '_denom_drop.sql'
				print('Calling ' + fname + ' ...')
				ret = mapping_util.execute_sql_file_parallel(db_conf, fname, False)
			if ret == True:
# ---------------------------------------------------------
# Ask the user for LOAD confirmation
# ---------------------------------------------------------
				qa = input('Are you sure you want to CREATE/LOAD the ' + database_type.upper() + ' denominators tables (y/n):') 
				while qa.lower() not in ['y', 'n', 'yes', 'no']:
					qa = input('I did not understand that. Are you sure you want to CREATE/LOAD all the ' + database_type.upper() + ' denominators tables (y/n):') 
				if qa.lower() in ['y', 'yes']:
# ---------------------------------------------------------
# Create denominators tables
# ---------------------------------------------------------
					fname = dir_sql + '7b_' + database_type + '_denom_create.sql'
					print('Calling ' + fname + ' ...')
					ret = mapping_util.execute_sql_file_parallel(db_conf, fname, False)
# ---------------------------------------------------------
# Load denominators data - Parallel execution
# ---------------------------------------------------------
					if ret == True:
						tbl_denom = 'tbl_' + database_type + '_denom'
						tbl_denom_list = [tbl for tbl in db_conf[tbl_denom]]
						file_denom_list = [[dir_denom + '*' + tbl + '.txt'] for tbl in tbl_denom_list]
						if not os.path.exists(dir_denom_processed):
							os.makedirs(dir_denom_processed)
						ret = mapping_util.load_files_parallel(db_conf, source_schema, tbl_denom_list, file_denom_list, dir_denom_processed)
						if ret == True:
							print('Finished loading cdm vocabulary.')
# ---------------------------------------------------------
# Ask the user for PK/IDX creation confirmation
# ---------------------------------------------------------
			if ret == True:
				qa = input('Are you sure you want to CREATE PK/IDXs on the ' + database_type.upper() + ' denominators tables (y/n):') 
				while qa.lower() not in ['y', 'n', 'yes', 'no']:
					qa = input('Are you sure you want to CREATE PK/IDXs on all the ' + database_type.upper() + ' denominators tables (y/n):') 
				if qa.lower() in ['y', 'yes']:
# ---------------------------------------------------------
# Build PKs & IDXs
# ---------------------------------------------------------
					print('Build PKs and IDXs ...')
					sql_file_list = sorted(glob.iglob(dir_sql + '7c_' + database_type + '_denom_pk_idx_*.sql'))
					ret = mapping_util.execute_sql_files_parallel(db_conf, sql_file_list, True)
					if ret == True:
						print('Finished adding ' + database_type.upper() + ' PKs/indexes')
# ---------------------------------------------------------
# Ask the user for RECORD COUNTS confirmation
# ---------------------------------------------------------
			if ret == True:
				qa = input('Are you sure you want to COUNT the records for all the ' + database_type.upper() + ' tables (y/n):') 
				while qa.lower() not in ['y', 'n', 'yes', 'no']:
					qa = input('Are you sure you want to COUNT the records for all the ' + database_type.upper() + ' tables (y/n):') 
				if qa.lower() in ['y', 'yes']:
					source_nok_schema = db_conf['source_nok_schema']
					tbl_list_count = tbl_db_list + [source_nok_schema + "." + tbl for tbl in db_conf[tbl_db] if tbl not in ('practice', 'staff')]
					ret = mapping_util.get_table_count_parallel(db_conf, tbl_list_count, source_schema + '._records')
					if ret == True:
						print('Finished counting on ' + database_type.upper() + ' data\n')	
# ---------------------------------------------------------
# Move CODE to the processed directory?
# ---------------------------------------------------------
			if ret == True:
				qa = input('Are you sure you want to MOVE all the source CODE in the "processed" folder (y/n):') 
				while qa.lower() not in ['y', 'n', 'yes', 'no']:
					qa = input('I did not understand that. Are you sure you want to MOVE all the source CODE in the "processed" folder (y/n):') 
				if qa.lower() in ['y', 'yes']:
					for f in glob.iglob(dir_sql + '1*.sql'):
						file_processed = dir_sql_processed + os.path.basename(f)
						os.rename(f, file_processed)
					print('Finished MOVING code files')	
	except:
		print(str(sys.exc_info()[1]))

# ---------------------------------------------------------
# Protect entry point
# ---------------------------------------------------------
if __name__ == "__main__":
	main()

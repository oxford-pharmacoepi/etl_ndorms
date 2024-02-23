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
			database_name = db_conf['database']
			result_schema = db_conf['result_schema']
			dir_sql = os.getcwd() + '\\sql_scripts\\'
			dir_sql_processed = os.getcwd() + '\\sql_scripts' + db_conf['dir_processed']
			dir_data = db_conf['dir_cdm_data'] + '/'
			dir_data_processed = db_conf['dir_cdm_data'] + db_conf['dir_processed']
			if not os.path.exists(dir_data_processed):
				os.makedirs(dir_data_processed)
# ---------------------------------------------------------
# Ask the user for DROP confirmation
# ---------------------------------------------------------
			qa = input('Are you sure you want to DROP ' + database_name + ' Achilles and DQD tables (y/n):') 
			while qa.lower() not in ['y', 'n', 'yes', 'no']:
				qa = input('I did not understand that. Are you sure you want to DROP ' + database_name + ' Achilles and DQD tables (y/n):') 
			if qa.lower() in ['y', 'yes']:
				fname = dir_sql + '9a_cdm_post_drop.sql'
				print('Calling ' + fname + ' ...')
				ret = mapping_util.execute_sql_file_parallel(db_conf, fname, False)
			if ret == True:
# ---------------------------------------------------------
# Ask the user for LOAD confirmation
# ---------------------------------------------------------
				qa = input('Are you sure you want to CREATE/LOAD ' + database_name + ' Achilles and DQD tables (y/n):') 
				while qa.lower() not in ['y', 'n', 'yes', 'no']:
					qa = input('I did not understand that. Are you sure you want to CREATE/LOAD ' + database_name + ' Achilles and DQD tables (y/n):') 
				if qa.lower() in ['y', 'yes']:
# ---------------------------------------------------------
# Create tables
# ---------------------------------------------------------
					fname = dir_sql + '9b_cdm_post_create.sql'
					print('Calling ' + fname + ' ...')
					ret = mapping_util.execute_sql_file_parallel(db_conf, fname, False)
# ---------------------------------------------------------
# Load data - Parallel execution
# ---------------------------------------------------------
					if ret == True:
						data_provider = db_conf['data_provider']
						prefix = ''
						with_quotes = False
						null_string = ''
						if data_provider == 'cprd':
							extension = '.txt'
							separator = '	'
						elif data_provider == 'iqvia':
							extension = '.csv' # + sorted(glob.iglob(folder + '\\*.out'))
							separator = '	'
						elif data_provider == 'thin':
							extension = '.csv'
							separator = ','
							with_quotes = True
							null_string = 'NA'
						elif data_provider == 'ukbiobank':
							extension = '.tsv'
							separator = '	'
						tbl_list = db_conf['tbl_cdm_post']
						tbl_list_full =  [result_schema + "." + tbl for tbl in tbl_list]
						print(tbl_list_full)
						file_list = [[dir_data + '*' + tbl + '*' + extension] for tbl in tbl_list]
						print(file_list)
						ret = mapping_util.load_files_parallel(db_conf, result_schema, tbl_list, file_list, dir_data_processed, separator, with_quotes, null_string)
						if ret == True:
							print('Finished loading cdm vocabulary.')
# ---------------------------------------------------------
# Ask the user for PK/IDX creation confirmation
# ---------------------------------------------------------
			if ret == True:
				qa = input('Are you sure you want to CREATE PK/IDXs on the ' + database_name + ' Achilles and DQD tables (y/n):') 
				while qa.lower() not in ['y', 'n', 'yes', 'no']:
					qa = input('Are you sure you want to CREATE PK/IDXs on all the ' + database_name + ' Achilles and DQD tables (y/n):') 
				if qa.lower() in ['y', 'yes']:
# ---------------------------------------------------------
# Build PKs & IDXs
# ---------------------------------------------------------
					print('Build PKs and IDXs ...')
					sql_file_list = sorted(glob.iglob(dir_sql + '9c_cdm_post_pk_idx_*.sql'))
					ret = mapping_util.execute_sql_files_parallel(db_conf, sql_file_list, True)
					if ret == True:
						print('Finished adding ' + database_name + ' Achilles/DQD PKs/indexes')
# ---------------------------------------------------------
# Ask the user for RECORD COUNTS confirmation
# ---------------------------------------------------------
			if ret == True:
				qa = input('Are you sure you want to COUNT the records for all the ' + database_name + ' tables (y/n):') 
				while qa.lower() not in ['y', 'n', 'yes', 'no']:
					qa = input('Are you sure you want to COUNT the records for all the ' + database_name + ' tables (y/n):') 
				if qa.lower() in ['y', 'yes']:
					source_nok_schema = db_conf['source_nok_schema']
					tbl_list_count = tbl_db_list + [source_nok_schema + "." + tbl for tbl in db_conf[tbl_db] if tbl not in ('practice', 'staff')]
					ret = mapping_util.get_table_count_parallel(db_conf, tbl_list_count, source_schema + '._records')
					if ret == True:
						print('Finished counting on ' + database_name + ' data\n')	
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

import os
import sys
import glob
import time
from datetime import datetime
#import psycopg3 as sql
from io import StringIO
from pathlib import Path
from random import shuffle
from concurrent.futures import ProcessPoolExecutor
from concurrent.futures import as_completed
from importlib.machinery import SourceFileLoader
from importlib import import_module

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
			target_schema = db_conf['target_schema']
			vocabulary_schema = db_conf['vocabulary_schema']
			dir_sql = os.getcwd() + '\\sql_scripts\\'
			dir_sql_processed = os.getcwd() + '\\sql_scripts' + db_conf['dir_processed']
			if not os.path.exists(dir_sql_processed):
				os.makedirs(dir_sql_processed)
			dir_cdm = db_conf['dir_cdm_data'] + '/'
			dir_cdm_processed = db_conf['dir_cdm_data'] + db_conf['dir_processed']
			if not os.path.exists(dir_cdm_processed):
				os.makedirs(dir_cdm_processed)
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
				fname = dir_sql + '4__schema_create.sql'
				print('Calling ' + fname + ' ...')
				ret = mapping_util.execute_sql_file_parallel(db_conf, fname, False, False)
			if ret == True:
# ---------------------------------------------------------
# Create/Recreate CDM tables? Parallel execution of queries in the file - Ask the user for DROP confirmation
# ---------------------------------------------------------
				qa = input('Are you sure you want to DROP/CREATE all the CDM tables (y/n):') 
				while qa.lower() not in ['y', 'n', 'yes', 'no']:
					qa = input('I did not understand that. Are you sure you want to DROP/CREATE all the CDM tables (y/n):') 
				if qa.lower() in ['y', 'yes']:
					fname = dir_sql + '4a_cdm_drop_tbl.sql'
					print('Calling ' + fname + ' ...')
					ret = mapping_util.execute_multiple_queries(db_conf, fname, None, None, True, debug)
					if ret == True:
						cdm_version = db_conf['cdm_version']
						if cdm_version == '5.3':
							fname = dir_sql + '4b_OMOPCDM_postgresql_5_3_ddl.sql'
						elif cdm_version[:3] == '5.4':
							fname = dir_sql + '4b_OMOPCDM_postgresql_5_4_ddl.sql'
						print('Calling ' + fname + ' ...')
						ret = mapping_util.execute_sql_file_parallel(db_conf, fname, False, True)
# ---------------------------------------------------------
# Load CDM tables - Parallel execution
# ---------------------------------------------------------
			if ret == True:
				qa = input('Are you sure you want to LOAD all the CDM tables (y/n):') 
				while qa.lower() not in ['y', 'n', 'yes', 'no']:
					qa = input('I did not understand that. Are you sure you want to LOAD all the CDM tables (y/n):') 
				if qa.lower() in ['y', 'yes']:
					data_provider = db_conf['data_provider']
					prefix = ''
					if data_provider == 'cprd':
						extension = '.txt'
						separator = '	'
					elif data_provider == 'iqvia':
						extension = '.csv' # + sorted(glob.iglob(folder + '\\*.out'))
						separator = '	'
					elif data_provider == 'thin':
						extension = '.csv'
						separator = ';'
						prefix = 'OMOP_'
					elif data_provider == 'ukbiobank':
						extension = '.tsv'
						separator = '	'
					if ret == True:
						tbl_cdm = [tbl for tbl in db_conf['tbl_cdm']]
						file_list = [[dir_cdm + prefix + tbl + '*' + extension] for tbl in tbl_cdm]
						ret = mapping_util.load_files_parallel(db_conf, target_schema, tbl_cdm, file_list, dir_cdm_processed, separator)
						if ret == True:
							print('Finished loading MAPPED data.')
	except:
		print(str(sys.exc_info()[1]))

# ---------------------------------------------------------
# Protect entry point
# ---------------------------------------------------------
if __name__ == "__main__":
	main()

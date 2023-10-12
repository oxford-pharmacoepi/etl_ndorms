import os
import sys
import time
import glob
import psycopg2 as sql
from datetime import datetime
from importlib import import_module
from importlib.machinery import SourceFileLoader

mapping_util = SourceFileLoader('mapping_util', os.path.dirname(os.path.realpath(__file__)) + '/mapping_util.py').load_module()
db_conf = import_module('__postgres_db_conf', os.getcwd() +'\\__postgres_db_conf.py').db_conf
log = import_module('write_log', os.getcwd() + '\\write_log.py').Log('3_load_cdm_vocabulary')
# ---------------------------------------------------------
# MAIN PROGRAM
# ---------------------------------------------------------
def main():
	ret = True
	
	try:
		study_directory = db_conf['dir_study']
		schema_voc = db_conf['vocabulary_schema']
#		dir_code = study_directory + "code\\sql_scripts\\"
		database_type = db_conf['database_type']
		dir_sql = os.getcwd() + '\\sql_scripts\\'
		dir_sql_processed = os.getcwd() + '\\sql_scripts' + db_conf['dir_processed']
		dir_voc = db_conf['dir_voc'] + "\\"		#study_directory + "vocabulary\\"
		dir_voc_processed = db_conf['dir_voc'] + db_conf['dir_processed']
# ---------------------------------------------------------
# Drop vocabularies tables - Parallel execution of queries in the file - Ask the user for DROP confirmation
# ---------------------------------------------------------
		drop_tbls = input('Are you sure you want to DROP all the CDM vocabulary tables (y/n):') 
		while drop_tbls.lower() not in ['y', 'n', 'yes', 'no']:
			drop_tbls = input('I did not understand that. Are you sure you want to DROP all the CDM vocabulary tables (y/n):') 
		if drop_tbls.lower() in ['y', 'yes']:
			fname = dir_sql + '3a_cdm_drop_vocabulary.sql'
			log.log_message('Calling ' + fname + ' ...')
			ret = mapping_util.execute_sql_file_parallel(fname, False)
# ---------------------------------------------------------
# Create vocabularies tables - Parallel execution of queries in the file - Ask the user for CREATE/LOAD confirmation
# ---------------------------------------------------------
		if ret == True:
			load_tbls = input('Are you sure you want to CREATE/LOAD all the vocabulary tables (y/n):') 
			while load_tbls.lower() not in ['y', 'n', 'yes', 'no']:
				load_tbls = input('I did not understand that. Are you sure you want to CREATE/LOAD all the vocabulary tables (y/n):') 
			if load_tbls.lower() in ['y', 'yes']:
				fname = dir_sql + '3b_cdm_create_vocabulary.sql'
				log.log_message('Calling ' + fname + ' ...')
				ret = mapping_util.execute_sql_file_parallel(fname, False)
# ---------------------------------------------------------
# Load vocabularies tables - Parallel execution
# ---------------------------------------------------------
				if ret == True:
					tbl_cdm_voc = [tbl for tbl in db_conf['tbl_cdm_voc']]
					file_list = [[dir_voc + tbl + '.csv'] for tbl in tbl_cdm_voc]
					if not os.path.exists(dir_voc_processed):
						os.makedirs(dir_voc_processed)
					ret = mapping_util.load_files_parallel(schema_voc, tbl_cdm_voc, file_list, dir_voc_processed)
					if ret == True:
						log.log_message('Finished loading cdm vocabulary.')
# ---------------------------------------------------------
# Create vocabularies PK, indexes - Parallel execution
# ---------------------------------------------------------
		if ret == True:
			load_tbls = input('Are you sure you want to CREATE PK/IDXs for all the vocabulary tables (y/n):') 
			while load_tbls.lower() not in ['y', 'n', 'yes', 'no']:
				load_tbls = input('I did not understand that. Are you sure you want to CREATE PK/IDXs for all the vocabulary tables (y/n):') 
			if load_tbls.lower() in ['y', 'yes']:
				log.log_message('Build PKs and IDXs ...')
				sql_file_list = sorted(glob.iglob(dir_sql + '3c_cdm_pk_idx_*.sql'))
				ret = mapping_util.execute_sql_files_parallel(sql_file_list, True)
# ---------------------------------------------------------
# CREATE/LOAD source_to_concept_vocab_map
# ---------------------------------------------------------
		if ret == True:
			load_tbls = input('Are you sure you want to CREATE/LOAD source_to_..._map tables (y/n):') 
			while load_tbls.lower() not in ['y', 'n', 'yes', 'no']:
				load_tbls = input('I did not understand that. Are you sure you want to CREATE/LOAD source_to_..._map tables tables (y/n):') 
			if load_tbls.lower() in ['y', 'yes']:
				fname = dir_sql + '3d_cdm_' + database_type + '_to_concept_vocab_map.sql'
				if os.path.isfile(fname) == True:
					log.log_message('Calling ' + fname + ' ...')
					ret = mapping_util.execute_multiple_queries(fname, None, None, True, True)
# ---------------------------------------------------------
# CREATE/LOAD source_to_source_vocab_map
# ---------------------------------------------------------
				if ret == True:
					fname = dir_sql + '3e_cdm_source_to_source_vocab_map.sql'
					log.log_message('Calling ' + fname + ' ...')
					ret = mapping_util.execute_multiple_queries(fname, None, None, True, True)
# ---------------------------------------------------------
# CREATE/LOAD source_to_standard_vocab_map
# ---------------------------------------------------------
				if ret == True:
					fname = dir_sql + '3f_cdm_source_to_standard_vocab_map.sql'
					log.log_message('Calling ' + fname + ' ...')
					ret = mapping_util.execute_multiple_queries(fname, None, None, True, True)
					if ret == True:
						log.log_message('Finished CDM vocabularies processing')
# ---------------------------------------------------------
# Move CODE to the processed directory?
# ---------------------------------------------------------
		if ret == True:
			load_tbls = input('Are you sure you want to MOVE all the vocabulary CODE in the "processed" folder (y/n):') 
			while load_tbls.lower() not in ['y', 'n', 'yes', 'no']:
				load_tbls = input('I did not understand that. Are you sure you want to MOVE all the vocabulary CODE in the "processed" folder (y/n):') 
			if load_tbls.lower() in ['y', 'yes']:
				for f in glob.iglob(dir_sql + '3*.sql'):
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

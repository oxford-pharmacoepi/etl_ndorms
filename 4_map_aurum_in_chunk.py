import os
import sys
import time
import datetime
import psycopg2 as sql
from importlib import import_module
from importlib.machinery import SourceFileLoader

mapping_util = SourceFileLoader('mapping_util', os.path.dirname(os.path.realpath(__file__)) + '/mapping_util.py').load_module()
db_conf = import_module('__postgres_db_conf', os.getcwd() + '\\__postgres_db_conf.py').db_conf
log = import_module('write_log', os.getcwd() + '\\write_log.py').Log('4_map_aurum_in_chunks')

source_schema = db_conf['source_schema']
target_schema = db_conf['target_schema']
chunk_size = db_conf['chunk_size']
chunk_limit = db_conf['chunk_limit']

# ---------------------------------------------------------
# MAIN PROGRAM
# ---------------------------------------------------------
def main():
	ret = True
	cnx = None
	
	try:
		time0 = time.time()
		if len(sys.argv) >= 2 and sys.argv[1].upper() == "-D":
			debug = True
		else:
			debug = False
		study_directory = db_conf['dir_study']
		dir_code = study_directory + "code\\sql_scripts\\"
# ---------------------------------------------------------
# Create/Recreate CDM tables? Parallel execution of queries in the file - Ask the user for DROP confirmation
# ---------------------------------------------------------
		drop_tbls = input('Are you sure you want to DROP/CREATE all the CDM tables (y/n):') 
		while drop_tbls.lower() not in ['y', 'n', 'yes', 'no']:
			drop_tbls = input('I did not understand that. Are you sure you want to DROP/CREATE all the CDM tables (y/n):') 
		if drop_tbls.lower() in ['y', 'yes']:
			fname = dir_code + '4a_cdm_drop_tbl.sql'
			log.log_message('Calling ' + fname + ' ...')
			ret = mapping_util.execute_sql_file_parallel(fname, False)
			if ret == True:
				fname = dir_code + '4b_OMOP CDM postgresql v5_3_1 ddl.sql'
				log.log_message('Calling ' + fname + ' ...')
				ret = mapping_util.execute_sql_file_parallel(fname, False)
# ---------------------------------------------------------
# Tables to load: LOCATION, CARE_SITE, PROVIDER, PERSON, DEATH, OBSERVATION_PERIOD
# ---------------------------------------------------------
		if ret == True:
			start_mapping = input('Do you want to map the simple tables: LOCATION, CARE_SITE, PROVIDER, PERSON, DEATH, OBSERVATION_PERIOD (y/n):').lower()
			while start_mapping not in ['y', 'n', 'yes', 'no']:
				start_mapping = input('I did not understand that. Do you want to map the simple tables: LOCATION, CARE_SITE, PROVIDER, PERSON, DEATH, OBSERVATION_PERIOD (y/n):') 
			if start_mapping in ['y', 'yes']:
				fname = dir_code + '4c_aurum_map_tbl_simple.sql'
				log.log_message('Executing ' + fname + ' ... (LOCATION, CARE_SITE, PROVIDER, PERSON, DEATH, OBSERVATION_PERIOD)')
				ret = mapping_util.execute_multiple_queries(fname, None, None, True, debug)
# ---------------------------------------------------------
# Tables to load: TEMP_CONCEPT_MAP, TEMP_DRUG_CONCEPT_MAP, TEMP_VISIT_DETAIL
# ---------------------------------------------------------
		if ret == True:
			reset_tbls_tmp = input('Do you want to CREATE/RECREATE the temp tables (temp_concept_map, temp_drug_concept_map, temp_visit_detail)? (y/n):').lower() 
			while reset_tbls_tmp not in ['y', 'n', 'yes', 'no']:
				reset_tbls_tmp = input('I did not understand that. Do you want to CREATE/RECREATE the temp tables (temp_concept_map, temp_drug_concept_map, temp_visit_detail? (y/n):').lower()
			if reset_tbls_tmp in ['y', 'yes']:
				fname = dir_code + '4d_aurum_map_tbl_tmp.sql'
				log.log_message('Executing ' + fname + ' ... (temp_concept_map, temp_drug_concept_map, temp_visit_detail)')
				ret = mapping_util.execute_multiple_queries(fname, None, None, True, debug)
# ---------------------------------------------------------
# Tables to load: VISIT_OCCURRENCE, VISIT_DETAIL
# ---------------------------------------------------------
		if ret == True:
			reset_tbls_visit = input('Do you want to CREATE/RECREATE the visit tables (visit_occurrence, visit_detail)? (y/n):').lower() 
			while reset_tbls_visit not in ['y', 'n', 'yes', 'no']:
				reset_tbls_visit = input('I did not understand that. Do you want to CREATE/RECREATE the visit tables (visit_occurrence, visit_detail)? (y/n):').lower()
			if reset_tbls_visit in ['y', 'yes']:
				fname = dir_code + '4e_aurum_map_tbl_visit.sql'
				log.log_message('Executing ' + fname + ' ... (visit_occurrence, visit_detail)')
				ret = mapping_util.execute_multiple_queries(fname, None, None, True, debug)
# ---------------------------------------------------------
# Connect to db
# ---------------------------------------------------------
		if ret == True:
			database = db_conf['database']
			cnx = sql.connect(
				user=db_conf['username'],
				password=db_conf['password'],
				database=database
			)
			cursor1 = cnx.cursor()
			cnx.autocommit = True
# ---------------------------------------------------------
# Insert record in cdm_source
# ---------------------------------------------------------
			vocabulary_schema = db_conf['vocabulary_schema']
			target_schema = db_conf['target_schema']
			source_release_date = db_conf['source_release_date']
			cdm_etl_reference = db_conf['cdm_etl_reference']
			cdm_version = db_conf['cdm_version']
			query1 = 'select 1 from ' + target_schema + '.cdm_source'
			cursor1.execute(query1)
			rec_found = cursor1.fetchone()
			if rec_found == None:
				query1 = 'INSERT INTO ' + target_schema + '.cdm_source \
					select \'' + \
					database + '\', \'' + \
					database + '\', \
					\'NDORMS\', \
					\'CPRD AURUM\', \
					\'https://ohdsi.github.io/ETL-LambdaBuilder/docs/CPRD_Aurum\', \'' + \
					cdm_etl_reference + '\', \
					TO_DATE(\'' + source_release_date + '\',\'YYYY-MM-DD\'), \
					case when \'' + cdm_version + '\' = \'5.3\' then TO_DATE(\'2021-09-25\', \'YYYY-MM-DD\') \
						when \'' + cdm_version + '\' = \'5.4\' then TO_DATE(\'2023-02-08\', \'YYYY-MM-DD\') end, \'' + \
					cdm_version + '\', \
					(SELECT vocabulary_version FROM ' + vocabulary_schema + '.vocabulary WHERE vocabulary_id = \'None\')'
				cursor1.execute(query1)
# ---------------------------------------------------------
# Create/Recreate CHUNK table and any chunk job previously done?
# ---------------------------------------------------------
			reset_tbls_chunk = input('Do you want to CREATE/RECREATE the chunk table and remove any chunk work previously done? (y/n):').lower() 
			while reset_tbls_chunk not in ['y', 'n', 'yes', 'no']:
				reset_tbls_chunk = input('I did not understand that. Do you want to CREATE/RECREATE the chunk table and remove any chunk work previously done? (y/n):').lower()
			if reset_tbls_chunk in ['y', 'yes']:
# ---------------------------------------------------------
# Delete possible old stem_source_x and stem_x tables
# ---------------------------------------------------------
				(ret, exist) = mapping_util.does_tbl_exist(cnx, "chunks.chunk")
				if ret == True and exist == True:
					query1 = f'SELECT stem_source_tbl, stem_tbl FROM chunks.chunk WHERE completed = 1'
					cursor1.execute(query1)
					tbl_array = cursor1.fetchall()
					stem_source_list = list(map(lambda x: x[0], tbl_array))
					stem_list = list(map(lambda x: x[1], tbl_array))
					for tbl_id in range(0,len(stem_source_list)):
						query1 = f'DROP TABLE IF EXISTS chunks.' + stem_source_list[tbl_id];
						cursor1.execute(query1)
						if stem_list[tbl_id] != None:
							query1 = f'DROP TABLE IF EXISTS chunks.' + stem_list[tbl_id];
							cursor1.execute(query1)
				fname = dir_code + '4f_aurum_map_tbl_chunk.sql'
				log.log_message('Executing ' + fname + ' ... (CHUNK)')
				ret = mapping_util.execute_multiple_queries(fname, None, None, True, debug)
# Necessary to recall 4b here if the CDM tables were deleted
				if ret == True:
					fname = dir_code + '4b_OMOP CDM postgresql v5_3_1 ddl.sql'
					log.log_message('Calling ' + fname + ' ...')
					ret = mapping_util.execute_sql_file_parallel(fname, False)
# ---------------------------------------------------------
# Start/Restart chunking
# ---------------------------------------------------------
		if ret == True:
			start_chunking = input('Would you like to progress with chunking? (y/n):').lower()
			while start_chunking not in ['y', 'n', 'yes', 'no']:
				start_chunking = input('I did not understand that. Would you like to progress with chunking? (y/n):').lower()
			if start_chunking in ['y', 'yes']:
# ---------------------------------------------------------
# Select not completed chunk ids
# ---------------------------------------------------------
				cnx.autocommit = False
				chunks_time1 = time.time()
				query1 = f'SELECT distinct chunk_id FROM chunks.chunk where completed = 0 order by chunk_id'
				if chunk_limit > 0:
					query1 += ' limit ' + str(chunk_limit)
				query1 += ';'
				cursor1.execute(query1)
				chunk_id_array = cursor1.fetchall()
				chunk_id_list = list(map(lambda x: x[0], chunk_id_array))
# ---------------------------------------------------------
# Loop through the chunks executing 4g, 4h and 4i each time before commit
# ---------------------------------------------------------
				for chunk_id in chunk_id_list:
					log.log_message(f'Executing chunk {str(chunk_id)} / {str(chunk_id_list[-1])}')
					chunk_time1 = time.time()
					fname = dir_code + '4g_aurum_map_tbl_stem_source.sql'
					log.log_message('Executing ' + fname + ' ... (STEM_SOURCE)')
					ret = mapping_util.execute_multiple_queries(fname, str(chunk_id), cnx, False, debug)
					if ret == True:
						fname = dir_code + '4h_aurum_map_tbl_stem.sql'
						log.log_message('Executing ' + fname + ' ... (STEM)')
						ret = mapping_util.execute_multiple_queries(fname, str(chunk_id), cnx, False, debug)
					if ret == True:
						fname = dir_code + '4i_aurum_map_tbl_cdm.sql'
						log.log_message('Executing ' + fname + ' ... (CONDITION_OCCURRENCE, DRUG_EXPOSURE, DEVICE_EXPOSURE, PROCEDURE_OCCURRENCE, MEASUREMENT, OBSERVATION)')
						ret = mapping_util.execute_multiple_queries(fname, str(chunk_id), cnx, False, debug)
					if ret == True:
						cnx.commit()
						msg = mapping_util.calc_time(time.time() - chunk_time1)
						log.log_message(f'Chunk {str(chunk_id)} finished in {msg}')
				if ret == True:
					msg = mapping_util.calc_time(time.time() - chunks_time1)
					log.log_message(f'Full CHUNK process completed in {msg}')
# ---------------------------------------------------------
# Count records per mapped table
# ---------------------------------------------------------
		if ret == True:
			cnx.autocommit = True
			records_tbl = target_schema + '._records'
			if mapping_util.does_tbl_exist(cnx, records_tbl) == True:
				query1 = "TRUNCATE " + records_tbl;
				cursor1.execute(query1)
				log.log_message('Counting rows in cdm tables ...')
#				tbl_cdm = ['LOCATION', 'CARE_SITE', 'PROVIDER', 'PERSON', 'DEATH', 'OBSERVATION_PERIOD', 'VISIT_OCCURRENCE', 'VISIT_DETAIL', 'CONDITION_OCCURRENCE', 'DRUG_EXPOSURE', 'DEVICE_EXPOSURE', 'PROCEDURE_OCCURRENCE', 'MEASUREMENT', 'OBSERVATION']
				tbl_cdm_list =  [tbl for tbl in db_conf['tbl_cdm']]
				tbl_cdm_list_full =  [target_schema + "." + tbl for tbl in tbl_cdm_list]
				for tbl in tbl_cdm_list_full:
					ret = mapping_util.get_table_count(cnx, tbl, target_schema + '._records')
			cnx.close()
# ---------------------------------------------------------
# Report total time
# ---------------------------------------------------------
		if ret == True:
			process_finished = "{0} completed in {1}".format(os.path.basename(__file__), mapping_util.calc_time(time.time() - time0))
			log.log_message(process_finished)
	except:
		if cnx != None:
			cnx.rollback()
		log.log_message(str(sys.exc_info()[1]))

# ---------------------------------------------------------
# Protect entry point
# ---------------------------------------------------------
if __name__ == "__main__":
	main()
	
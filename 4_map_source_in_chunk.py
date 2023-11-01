import os
import sys
import time
import datetime
import psycopg2 as sql
from importlib.machinery import SourceFileLoader

mapping_util = SourceFileLoader('mapping_util', os.path.dirname(os.path.realpath(__file__)) + '/mapping_util.py').load_module()

# ---------------------------------------------------------
# MAIN PROGRAM
# ---------------------------------------------------------
def main():
	ret = True
	cnx = None
	
	try:
		(ret, dir_study, db_conf, debug) = mapping_util.get_parameters()
		if ret == True and dir_study != '':
			time0 = time.time()
			database_type = db_conf['database_type']
			dir_sql = os.getcwd() + "\\sql_scripts\\"
			dir_sql_processed = os.getcwd() + '\\sql_scripts' + db_conf['dir_processed']
			if not os.path.exists(dir_sql_processed):
				os.makedirs(dir_sql_processed)
# ---------------------------------------------------------
# Create/Recreate CDM tables? Parallel execution of queries in the file - Ask the user for DROP confirmation
# ---------------------------------------------------------
			qa = input('Are you sure you want to DROP/CREATE all the CDM tables (y/n):') 
			while qa.lower() not in ['y', 'n', 'yes', 'no']:
				qa = input('I did not understand that. Are you sure you want to DROP/CREATE all the CDM tables (y/n):') 
			if qa.lower() in ['y', 'yes']:
				fname = dir_sql + '4a_cdm_drop_tbl.sql'
				print('Calling ' + fname + ' ...')
				ret = mapping_util.execute_sql_file_parallel(db_conf, fname, False)
				if ret == True:
					cdm_version = db_conf['cdm_version']
					if cdm_version == '5.3':
						fname = dir_sql + '4b_OMOPCDM_postgresql_5_3_ddl.sql'
					elif cdm_version == '5.4':
						fname = dir_sql + '4b_OMOPCDM_postgresql_5_4_ddl.sql'
					print('Calling ' + fname + ' ...')
					ret = mapping_util.execute_sql_file_parallel(db_conf, fname, False)
# ---------------------------------------------------------
# Tables to load: PERSON,OBSERVATION_PERIOD, etc.
# ---------------------------------------------------------
			if ret == True:
				qa = input('Do you want to map the simple tables: PERSON, OBSERVATION_PERIOD, etc. (y/n):').lower()
				while qa not in ['y', 'n', 'yes', 'no']:
					qa = input('I did not understand that. Do you want to map the simple tables: LOCATION, CARE_SITE, PROVIDER, PERSON, DEATH, OBSERVATION_PERIOD (y/n):') 
				if qa in ['y', 'yes']:
					fname = dir_sql + '4c_' + database_type + '_map_tbl_simple.sql'
					print('Executing ' + fname + ' ... (PERSON,OBSERVATION_PERIOD, etc.)')
					ret = mapping_util.execute_multiple_queries(db_conf, fname, None, None, True, debug)
# ---------------------------------------------------------
# Tables to load: TEMP_CONCEPT_MAP, TEMP_DRUG_CONCEPT_MAP, TEMP_VISIT_DETAIL
# ---------------------------------------------------------
			if ret == True:
				if database_type == 'aurum':
					qa = input('Do you want to CREATE/RECREATE the temp tables (temp_concept_map, temp_drug_concept_map, temp_visit_detail)? (y/n):').lower() 
					while qa not in ['y', 'n', 'yes', 'no']:
						qa = input('I did not understand that. Do you want to CREATE/RECREATE the temp tables (temp_concept_map, temp_drug_concept_map, temp_visit_detail? (y/n):').lower()
					if qa in ['y', 'yes']:
						fname = dir_sql + '4d_' + database_type + '_map_tbl_tmp.sql'
						print('Executing ' + fname + ' ... (temp_concept_map, temp_drug_concept_map, temp_visit_detail)')
						ret = mapping_util.execute_multiple_queries(db_conf, fname, None, None, True, debug)
# ---------------------------------------------------------
# Tables to load: VISIT_OCCURRENCE, VISIT_DETAIL
# ---------------------------------------------------------
			if ret == True:
				qa = input('Do you want to CREATE/RECREATE the visit tables (visit_occurrence, visit_detail)? (y/n):').lower() 
				while qa not in ['y', 'n', 'yes', 'no']:
					qa = input('I did not understand that. Do you want to CREATE/RECREATE the visit tables (visit_occurrence, visit_detail)? (y/n):').lower()
				if qa in ['y', 'yes']:
					fname = dir_sql + '4e_' + database_type + '_map_tbl_visit.sql'
					print('Executing ' + fname + ' ... (visit_occurrence, visit_detail)')
					ret = mapping_util.execute_multiple_queries(db_conf, fname, None, None, True, debug)
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
				chunk_schema = db_conf['chunk_schema']
				source_release_date = db_conf['source_release_date']
				source_description = db_conf['data_provider'] + ' ' + database_type
				cdm_holder = 'NDORMS'
				source_documentation_reference = 'https://github.com/oxford-pharmacoepi/etl_ndorms' 
				cdm_etl_reference = db_conf['cdm_etl_reference']
				cdm_version = db_conf['cdm_version']
				query1 = 'select 1 from ' + target_schema + '.cdm_source'
				cursor1.execute(query1)
				rec_found = cursor1.fetchone()
				if rec_found == None:
					print('Inserting record in CDM_SOURCE ...')
					query1 = 'INSERT INTO ' + target_schema + '.cdm_source \
						select \
						\'' + database + '\', \
						\'' + database[:25] + '\', \
						\'' + cdm_holder + '\', \
						\'' + source_description + '\', \
						\'' + source_documentation_reference + '\', \
						\'' + cdm_etl_reference + '\', \
						TO_DATE(\'' + source_release_date + '\',\'YYYY-MM-DD\'), \
						CURRENT_DATE, \'' + \
						cdm_version + '\', \
						(SELECT vocabulary_version FROM ' + vocabulary_schema + '.vocabulary WHERE vocabulary_id = \'None\')'
					cursor1.execute(query1)
# ---------------------------------------------------------
# Create/Recreate CHUNK table and any chunk job previously done?
# ---------------------------------------------------------
				qa = input('Do you want to CREATE/RECREATE the chunk table and remove any chunk work previously done? (y/n):').lower() 
				while qa not in ['y', 'n', 'yes', 'no']:
					qa = input('I did not understand that. Do you want to CREATE/RECREATE the chunk table and remove any chunk work previously done? (y/n):').lower()
				if qa in ['y', 'yes']:
# ---------------------------------------------------------
# Delete possible old stem_source_x and stem_x tables
# ---------------------------------------------------------
					(ret, exist) = mapping_util.does_tbl_exist(cnx, chunk_schema + '.chunk')
					if ret == True and exist == True:
						query1 = 'SELECT stem_source_tbl, stem_tbl FROM ' + chunk_schema + '.chunk WHERE completed = 1'
						cursor1.execute(query1)
						tbl_array = cursor1.fetchall()
						stem_source_list = list(map(lambda x: x[0], tbl_array))
						stem_list = list(map(lambda x: x[1], tbl_array))
						for tbl_id in range(0,len(stem_source_list)):
							query1 = 'DROP TABLE IF EXISTS ' + chunk_schema + '.' + stem_source_list[tbl_id];
							cursor1.execute(query1)
							if stem_list[tbl_id] != None:
								query1 = 'DROP TABLE IF EXISTS ' + chunk_schema + '.' + stem_list[tbl_id];
								cursor1.execute(query1)
					fname = dir_sql + '4f_' + database_type + '_map_tbl_chunk.sql'
					print('Executing ' + fname + ' ... (CHUNK)')
					ret = mapping_util.execute_multiple_queries(db_conf, fname, None, None, True, debug)
# Necessary to recall 4b here if the CDM tables were deleted
					if ret == True:
						cdm_version = db_conf['cdm_version']
						if cdm_version == '5.3':
							fname = dir_sql + '4b_OMOPCDM_postgresql_5_3_ddl.sql'
						elif cdm_version == '5.4':
							fname = dir_sql + '4b_OMOPCDM_postgresql_5_4_ddl.sql'
						print('Calling ' + fname + ' ...')
						ret = mapping_util.execute_sql_file_parallel(db_conf, fname, False, False)
# ---------------------------------------------------------
# Start/Restart chunking
# ---------------------------------------------------------
			if ret == True:
				qa = input('Would you like to progress with chunking? (y/n):').lower()
				while qa not in ['y', 'n', 'yes', 'no']:
					qa = input('I did not understand that. Would you like to progress with chunking? (y/n):').lower()
				if qa in ['y', 'yes']:
# ---------------------------------------------------------
# Select not completed chunk ids
# ---------------------------------------------------------
					cnx.autocommit = False
					chunks_time1 = time.time()
					query1 = 'SELECT distinct chunk_id FROM ' + chunk_schema + '.chunk where completed = 0 order by chunk_id'
					chunk_limit = db_conf['chunk_limit']
					if chunk_limit > 0:
						query1 += ' limit ' + str(chunk_limit)
					query1 += ';'
					cursor1.execute(query1)
					chunk_id_array = cursor1.fetchall()
					chunk_id_list = list(map(lambda x: x[0], chunk_id_array))
# ---------------------------------------------------------
# Loop through the chunks executing 4g, 4h and 4i each time before commit
# ---------------------------------------------------------
					move_files = False
					for chunk_id in chunk_id_list:
						print(f'Executing chunk {str(chunk_id)} / {str(chunk_id_list[-1])}')
						chunk_time1 = time.time()
						if chunk_id == chunk_id_list[-1]:
							move_files = True
						fname = dir_sql + '4g_' + database_type + '_map_tbl_stem_source.sql'
						print('Executing ' + fname + ' ... (STEM_SOURCE)')
						ret = mapping_util.execute_multiple_queries(db_conf, fname, str(chunk_id), cnx, False, debug, move_files)
						if ret == True:
							fname = dir_sql + '4h_' + database_type + '_map_tbl_stem.sql'
							print('Executing ' + fname + ' ... (STEM)')
							ret = mapping_util.execute_multiple_queries(db_conf, fname, str(chunk_id), cnx, False, debug, move_files)
						if ret == True:
							fname = dir_sql + '4i_' + database_type + '_map_tbl_cdm.sql'
							print('Executing ' + fname + ' ... (CONDITION_OCCURRENCE, DRUG_EXPOSURE, DEVICE_EXPOSURE, PROCEDURE_OCCURRENCE, MEASUREMENT, OBSERVATION)')
							ret = mapping_util.execute_multiple_queries(db_conf, fname, str(chunk_id), cnx, False, debug, move_files)
						if ret == True:
							cnx.commit()
							msg = mapping_util.calc_time(time.time() - chunk_time1)
							print(f'Chunk {str(chunk_id)} finished in {msg}')
						if ret == False:
							break
					if ret == True:
						msg = mapping_util.calc_time(time.time() - chunks_time1)
						print(f'Full CHUNK process completed in {msg}')
			cnx.close()
# ---------------------------------------------------------
# Report total time
# ---------------------------------------------------------
			if ret == True:
				process_finished = "{0} completed in {1}".format(os.path.basename(__file__), mapping_util.calc_time(time.time() - time0))
				print(process_finished)
# ---------------------------------------------------------
# Move CODE to the processed directory?
# ---------------------------------------------------------
			if ret == True:
				qa = input('Are you sure you want to MOVE all the vocabulary CODE in the "processed" folder (y/n):') 
				while qa.lower() not in ['y', 'n', 'yes', 'no']:
					qa = input('I did not understand that. Are you sure you want to MOVE all the vocabulary CODE in the "processed" folder (y/n):') 
				if qa.lower() in ['y', 'yes']:
					for f in glob.iglob(dir_sql + '3*.sql'):
						file_processed = dir_sql_processed + os.path.basename(f)
						os.rename(f, file_processed)
					print('Finished MOVING code files')	
	except:
		if cnx != None:
			cnx.rollback()
		print(str(sys.exc_info()[1]))

# ---------------------------------------------------------
# Protect entry point
# ---------------------------------------------------------
if __name__ == "__main__":
	main()
	
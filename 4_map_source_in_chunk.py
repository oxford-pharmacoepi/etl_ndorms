import os
import sys
import glob
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
# Create the schemas, if not present
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
				ret = mapping_util.execute_multiple_queries(db_conf, fname, None, None, True, debug, False)
				if ret == True:
					cdm_version = db_conf['cdm_version']
					if cdm_version[:3] == '5.3':
						fname = dir_sql + '4b_OMOPCDM_postgresql_5_3_ddl.sql'
					elif cdm_version[:3] == '5.4':
						fname = dir_sql + '4b_OMOPCDM_postgresql_5_4_ddl.sql'
					print('Calling ' + fname + ' ...')
					ret = mapping_util.execute_sql_file_parallel(db_conf, fname, False, False)
# ---------------------------------------------------------
# Connect to db
# ---------------------------------------------------------
			if ret == True:
				database = db_conf['database']
				cnx = sql.connect(
					user=db_conf['username'],
					password=db_conf['password'],
					database=database,
					port=db_conf['port']
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
						cdm_version[0:3] + '\','				#the minor-version will fail to run DQD
					if cdm_version[0:3] >= '5.4':
						query1 += '(select concept_id from ' + vocabulary_schema + '.concept WHERE domain_id = \'Metadata\' \
									and standard_concept = \'S\' \
									and invalid_reason is null \
									and position(lower(\'OMOP CDM Version\') in lower(concept_name)) > 0 \
									and position(\'' + cdm_version + '\' in concept_name) > 0), '
					query1 += '(SELECT vocabulary_version FROM ' + vocabulary_schema + '.vocabulary WHERE vocabulary_id = \'None\')'
					cursor1.execute(query1)
# ---------------------------------------------------------
# If this is a linked dataset, create/recreate _max_ids table in target_schema_to_link
# ---------------------------------------------------------
			if ret == True:
				if 'target_schema_to_link' in db_conf and db_conf['target_schema_to_link'] != '' \
					and db_conf['target_schema_to_link'] != db_conf['target_schema']:
					target_schema_to_link = db_conf['target_schema_to_link']
					qa = input('Do you want to CREATE/RECREATE ' + target_schema_to_link.upper() + '._max_ids and ' + target_schema.upper() + '._next_ids? (y/n):').lower() 
					while qa not in ['y', 'n', 'yes', 'no']:
						qa = input('I did not understand that. Do you want to CREATE/RECREATE the _max_ids table in ' + db_conf['target_schema_to_link'] + '? (y/n):').lower()
					if qa in ['y', 'yes']:
						tbl_max_ids = target_schema_to_link + '._max_ids'
						query1 = 'DROP TABLE IF EXISTS ' + tbl_max_ids + ' CASCADE';
						cursor1.execute(query1)
						query1 = 'CREATE TABLE ' + tbl_max_ids + ' \
								(tbl_name varchar(25) NOT NULL, \
								max_id bigint DEFAULT 0) TABLESPACE pg_default;'
						cursor1.execute(query1)
						time1 = time.time()
						tbl_list_count = [target_schema_to_link + "." + tbl for tbl in db_conf['tbl_cdm']]
						ret = mapping_util.get_table_max_ids_parallel(db_conf, tbl_list_count, tbl_max_ids)
						if ret == True:
							query1 = 'with cte as (SELECT MAX(max_id) as max_id FROM ' + tbl_max_ids + ' WHERE tbl_name in \
									(\'condition_occurrence\', \'device_exposure\', \'drug_exposure\', \'measurement\', \
									\'observation\', \'procedure_occurrence\', \'specimen\', \'visit_detail\', \'visit_occurrence\')) \
									INSERT INTO ' + tbl_max_ids + ' (tbl_name, max_id) \
									SELECT \'max_of_all\', max_id \
									FROM cte';
							cursor1.execute(query1)
							query1 = 'ALTER TABLE ' + tbl_max_ids + ' ADD CONSTRAINT pk_max_ids PRIMARY KEY (tbl_name) USING INDEX TABLESPACE pg_default;'
							cursor1.execute(query1)
# Update _max_ids without records if it is not a primary dataset
#							if 'gold' not in target_schema_to_link and 'aurum' not in target_schema_to_link:
#								tbl_next_ids = target_schema_to_link + '._next_ids'
#								query1 = 'UPDATE ' + tbl_max_ids + ' as t1 \
#										SET max_id = t2.next_id - 1 \
#										from ' + tbl_next_ids + ' as t2 \
#										where t1.tbl_name = t2.tbl_name \
#										and t1.max_id = 0';
#								cursor1.execute(query1)
# Create table target_schema._next_ids
							tbl_next_ids = target_schema + '._next_ids'
							query1 = 'DROP TABLE IF EXISTS ' + tbl_next_ids + ' CASCADE';
							cursor1.execute(query1)
							query1 = 'CREATE TABLE ' + tbl_next_ids + ' \
									(tbl_name varchar(25) NOT NULL, \
									next_id bigint DEFAULT 0) TABLESPACE pg_default;'
							cursor1.execute(query1)
							query1 = 'INSERT INTO ' + tbl_next_ids + ' SELECT tbl_name, COALESCE(max_id+1,0) FROM ' + tbl_max_ids;
							cursor1.execute(query1)
							time1 = time.time()
							msg = 'Finished calculating max_ids in ' + target_schema_to_link.upper() + ' and next_ids in ' + target_schema.upper() + ' in ' + mapping_util.calc_time(time.time() - time1) + '\n'
							print(msg)
# ---------------------------------------------------------
# Tables to load: PERSON, OBSERVATION_PERIOD, etc.
# ---------------------------------------------------------
			if ret == True:
				qa = input('Do you want to map the simple tables: PERSON, OBSERVATION_PERIOD, etc. (y/n):').lower()
				while qa not in ['y', 'n', 'yes', 'no']:
					qa = input('I did not understand that. Do you want to map the simple tables: LOCATION, CARE_SITE, PROVIDER, PERSON, DEATH, OBSERVATION_PERIOD (y/n):') 
				if qa in ['y', 'yes']:
					fname = dir_sql + '4c_' + database_type + '_map_tbl_simple.sql'
					print('Executing ' + fname + ' ... (PERSON, OBSERVATION_PERIOD, etc.)')
					ret = mapping_util.execute_multiple_queries(db_conf, fname, None, None, True, debug, False)
# ---------------------------------------------------------
# Tables to load: TEMP_CONCEPT_MAP, TEMP_DRUG_CONCEPT_MAP, TEMP_VISIT_DETAIL
# ---------------------------------------------------------
			if ret == True:
				if database_type in ['aurum', 'ukb_baseline', 'ukb_gp', 'ukb_hesin', 'ukb_cancer', 'ncrascr1', 'ncrascr2']:
					qa = input('Do you want to CREATE/RECREATE the temp tables (TEMP_CONCEPT_MAP, TEMP_DRUG_CONCEPT_MAP, TEMP_VISIT_DETAIL)? (y/n):').lower() 
					while qa not in ['y', 'n', 'yes', 'no']:
						qa = input('I did not understand that. Do you want to CREATE/RECREATE the temp tables (TEMP_CONCEPT_MAP, TEMP_DRUG_CONCEPT_MAP, TEMP_VISIT_DETAIL? (y/n):').lower()
					if qa in ['y', 'yes']:
						fname = dir_sql + '4d' + db_conf['cdm_version'][2] + '_' + database_type + '_map_tbl_tmp.sql'
						print('Executing ' + fname + ' ... (TEMP_CONCEPT_MAP, TEMP_DRUG_CONCEPT_MAP, TEMP_VISIT_DETAIL)')
						ret = mapping_util.execute_multiple_queries(db_conf, fname, None, None, True, debug, False)
# ---------------------------------------------------------
# Tables to load: VISIT_OCCURRENCE, VISIT_DETAIL
# ---------------------------------------------------------
			if ret == True:
				if 'ukb'!= database_type: #ukb baseline has no event tables
					qa = input('Do you want to CREATE/RECREATE the visit tables (VISIT_OCCURRENCE, VISIT_DETAIL)? (y/n):').lower() 
					while qa not in ['y', 'n', 'yes', 'no']:
						qa = input('I did not understand that. Do you want to CREATE/RECREATE the visit tables (VISIT_OCCURRENCE, VISIT_DETAIL)? (y/n):').lower()
					if qa in ['y', 'yes']:
						fname = dir_sql + '4e' + db_conf['cdm_version'][2] + '_' + database_type + '_map_tbl_visit.sql'
						print('Executing ' + fname + ' ... (VISIT_OCCURRENCE, VISIT_DETAIL)')
						ret = mapping_util.execute_multiple_queries(db_conf, fname, None, None, True, debug, False)
# ---------------------------------------------------------
# Create/Recreate CHUNK table and any chunk job previously done?
# ---------------------------------------------------------
			if ret == True:
				if database_type == 'ukb_baseline':
					qa = input('Do you want to PROCEED with UKBB baseline MEASUREMENTS/OBSERVATIONS mapping? (y/n):').lower() 
					while qa not in ['y', 'n', 'yes', 'no']:
						qa = input('I did not understand that. Do you want to PROCEED with UKBB baseline MEASUREMENTS/OBSERVATIONS mapping? (y/n):').lower()
					if qa in ['y', 'yes']:
						fname = dir_sql + '4i' + db_conf['cdm_version'][2] + '_' + database_type + '_map_tbl_cdm.sql'
						print('Executing ' + fname + ' ... (MEASUREMENT)')
						ret = mapping_util.execute_multiple_queries(db_conf, fname, None, cnx, True, debug, False)
					
				elif database_type not in ('hesop'): #They do not use STEM and do not need chunking 
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
						fname = dir_sql + '4f_' + (database_type[:7] if (database_type[:7] == 'ncrascr') else database_type) + '_map_tbl_chunk.sql'
						print('Executing ' + fname + ' ... (CHUNK)')
						ret = mapping_util.execute_multiple_queries(db_conf, fname, None, None, True, debug, False)
# Necessary to recall 4b here if the CDM tables were deleted
						if ret == True:
							cdm_version = db_conf['cdm_version']
							if cdm_version[:3] == '5.3':
								fname = dir_sql + '4b_OMOPCDM_postgresql_5_3_ddl.sql'
							elif cdm_version[:3] == '5.4':
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
# Analyse already created tables before chunking
# ---------------------------------------------------------
							tbl_list = [target_schema + "." + tbl for tbl in ('care_site', 'death', 'location', 'observation_period', 'person', 'provider', 'visit_detail', 'visit_occurrence')]
							for tbl in tbl_list:
								query1 = 'VACUUM (ANALYZE) ' + tbl
								print('Executing ' + query1)
								cursor1.execute(query1)
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
# Temporary disable Autovacuum while chunking
							tbl_list = [target_schema + "." + tbl for tbl in db_conf['tbl_cdm']]
							for tbl in tbl_list:
								query1 = 'ALTER TABLE ' + tbl + ' SET (autovacuum_enabled = False)'
								cursor1.execute(query1)
# ---------------------------------------------------------
# Loop through the chunks executing 4g, 4h and 4i each time before commit
# ---------------------------------------------------------
							move_files = False
							for chunk_id in chunk_id_list:
								print(f'Executing chunk {str(chunk_id)} / {str(chunk_id_list[-1])}')
								chunk_time1 = time.time()
								fname = dir_sql + '4g_' + database_type + '_map_tbl_stem_source.sql'
								print('Executing ' + fname + ' ... (STEM_SOURCE)')
								ret = mapping_util.execute_multiple_queries(db_conf, fname, str(chunk_id), cnx, False, debug, move_files)
								if ret == True:
									fname = dir_sql + '4h_' + database_type + '_map_tbl_stem.sql'
									print('Executing ' + fname + ' ... (STEM)')
									ret = mapping_util.execute_multiple_queries(db_conf, fname, str(chunk_id), cnx, False, debug, move_files)
								if ret == True:
									fname = dir_sql + '4i' + db_conf['cdm_version'][2] + '_' + (database_type[:7] if (database_type[:7] == 'ncrascr') else database_type) + '_map_tbl_cdm.sql'
									print('Executing ' + fname + ' ... (CONDITION_OCCURRENCE, DEVICE_EXPOSURE, DRUG_EXPOSURE, MEASUREMENT, OBSERVATION, PROCEDURE_OCCURRENCE, SPECIMEN)')
									ret = mapping_util.execute_multiple_queries(db_conf, fname, str(chunk_id), cnx, False, debug, move_files)
								if ret == True:
									cnx.commit()
									msg = mapping_util.calc_time(time.time() - chunk_time1)
									print(f'Chunk {str(chunk_id)} finished in {msg}')
								if ret == False:
									break
							if ret == True:
# Analyse tables after chunking
								cnx.autocommit = True
								for tbl in tbl_list:
									query1 = 'VACUUM (ANALYZE) ' + tbl
									print('Executing ' + query1)
									cursor1.execute(query1)
# Re-enable Autovacuum after chunking
								for tbl in tbl_list:
									query1 = 'ALTER TABLE ' + tbl + ' SET (autovacuum_enabled = True)'
									cursor1.execute(query1)
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
				qa = input('Are you sure you want to MOVE all the mapping CODE in the "processed" folder (y/n):') 
				while qa.lower() not in ['y', 'n', 'yes', 'no']:
					qa = input('I did not understand that. Are you sure you want to MOVE all the mapping CODE in the "processed" folder (y/n):') 
				if qa.lower() in ['y', 'yes']:
					for f in glob.iglob(dir_sql + '4*.sql'):
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
	
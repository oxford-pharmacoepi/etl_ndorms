import os
import sys
import time
import glob
import psycopg2 as sql
from datetime import datetime
from importlib import import_module
from importlib.machinery import SourceFileLoader
import csv

mapping_util = SourceFileLoader('mapping_util', os.path.dirname(os.path.realpath(__file__)) + '/mapping_util.py').load_module()

# ---------------------------------------------------------
# Function: EXPORT CSV 
# - Select rows from Database and then writ to a CSV
# @param query 		Select SQL 
# @param params		params for the Select SQL
# @param fcsv		return csv file name	
# @param debug		flag of debug
# ---------------------------------------------------------
# ---------------------------------------------------------
def export_csv(query, params, fcsv, debug):
# ---------------------------------------------------------
	ret = False

	try:
		cnx = sql.connect(
			user=db_conf['username'],
			password=db_conf['password'],
			database=db_conf['database']
		)
		cursor1 = cnx.cursor()
		cnx.autocommit = True
		if debug:
			time1 = time.time()
			msg = '[' + datetime.now().strftime("%d/%m/%Y, %H:%M:%S") + '] Processing: ' + query
			print(msg)
			
		cursor1.execute(query, (params,))	

		data = cursor1.fetchall()
		if not data:
			if fcsv.__contains__('_suggestion'):
				print('All STCM target_concept_ids are standard.')
			else:
				print('No record has been found in table')
		else:
			headers = [i[0] for i in cursor1.description]
			with open(fcsv, 'w') as csvFile:
				# Create CSV writer.   
				#writer = csv.writer(csvFile, delimiter=',', lineterminator='\r', quoting=csv.QUOTE_NONE, escapechar='\\')
				writer = csv.writer(csvFile, delimiter=',', lineterminator='\r', quoting=csv.QUOTE_MINIMAL)

				# Add the headers and data to the CSV file.
				writer.writerow(headers)
				# Add data
				writer.writerows(data)

			csvFile.close()
			print("%s has been created." %(os.path.basename(fcsv)))

		if debug:
			msg = '[' + datetime.now().strftime("%d/%m/%Y, %H:%M:%S") + '] Query execution time: '
			msg += mapping_util.calc_time(time.time() - time1) + "\n"
			print(msg)

		cursor1.close()
		cursor1 = None

		ret = True

	except:
		ret = False
		err = sys.exc_info()
		print("Function = {0}, Error = {1}, {2}".format("export_csv", err[0], err[1]))
		if cursor1 != None:
			cursor1.close()
		cnx.close()

	return(ret)	

# ---------------------------------------------------------
# Function: CHECK STCM 
# - Select all non-standard, invalid target_concept_ids in every STCM
# - Generate csv with suggested target_concept_ids by STCM if applicable 
# @param fname 		SQL file name
# @param stcm		Name of the STCM
# @param debug		flag of debug
# ---------------------------------------------------------
def check_stcm(fname, stcm, debug):
# ---------------------------------------------------------
	ret = False
	
	try:
		dir_suggest_stcm = db_conf['dir_stcm'] + '\\suggestion' 
		dir_processed = dir_suggest_stcm + '\\' + db_conf['dir_processed']
		fcsv = dir_suggest_stcm + '\\' + stcm + '_suggestion' + '.csv'		# The suggestion CSV file name.

		if not os.path.exists(dir_suggest_stcm):
			os.makedirs(dir_suggest_stcm)

		if not os.path.exists(dir_processed):
			os.makedirs(dir_processed)		

		query = mapping_util.parse_queries_file(fname)[0]

		print("Checking %s in database..." %stcm)

		ret = export_csv(query, stcm, fcsv, debug)
	except:
		ret = False
		err = sys.exc_info()
		print("Function = {0}, Error = {1}, {2}".format("check_stcm", err[0], err[1]))

	return(ret)	

# ---------------------------------------------------------
# Function: UPDATE STCM 
# - Read the GOLD_XXX_STCM_suggestion CSVs to check the update_as_suggested = Y
# - Update STCM in database if update_as_suggested = Y
# - Move the GOLD_XXX_STCM_suggestion csv to processed
# - Rename the original STCM CSV as GOLD_XXX_STCM_old
# - Generate a new STCM CSV as GOLD_XXX_STCM for the next release.
# @param fname 		SQL file name
# @param fcsv		suggestion csv file name
# @param debug		flag of debug
# ---------------------------------------------------------
def update_stcm(fname, fcsv, debug):
# ---------------------------------------------------------
	updated = False
	i = 0 #no of rows being updated

	try:
		queries = mapping_util.parse_queries_file(fname)

		cnx = sql.connect(
			user=db_conf['username'],
			password=db_conf['password'],
			database=db_conf['database']
		)
		cursor1 = cnx.cursor()
		cnx.autocommit = False			

		print("Reading %s ..." %(os.path.basename(fcsv)))
		print("Updating the stcm ...")

		with open(fcsv, 'r') as f:
			d_reader = csv.DictReader(f)

			for line in d_reader:
                #update stcm target_concept_id
				if debug:
					time1 = time.time()
					msg = '[' + datetime.now().strftime("%d/%m/%Y, %H:%M:%S") + '] Processing: ' + queries[0]
					print(msg)

				cursor1.execute(queries[0], (
                                                line['target_concept_id'], 
                                                line['vocabulary_id'],
                                                line['valid_start_date'],
                                                line['valid_end_date'],
                                                line['source_vocabulary_id'], line['source_code']       #where clause
                                            ))
				if debug:
					time1 = time.time()
					msg = '[' + datetime.now().strftime("%d/%m/%Y, %H:%M:%S") + '] Processing: ' + queries[1]
					print(msg)

				cursor1.execute(queries[1], (line['source_vocabulary_id'], line['source_code']))

				if debug:
					time1 = time.time()
					msg = '[' + datetime.now().strftime("%d/%m/%Y, %H:%M:%S") + '] Processing: ' + queries[2]
					print(msg)

				cursor1.execute(queries[2], (line['source_vocabulary_id'], line['source_code']))
                
				i+=1

				if debug:
					msg = '[' + datetime.now().strftime("%d/%m/%Y, %H:%M:%S") + '] Query execution time: '
					msg += mapping_util.calc_time(time.time() - time1) + "\n"
					print(msg)
		
		cnx.commit()
		cursor1.close()
		cursor1 = None
		cnx.close()

		f.close()
		updated = True
		print("Finished updating stcm")

	except:
		updated = False
		err = sys.exc_info()
		print("Function = {0}, Error = {1}, {2}".format("update_stcm", err[0], err[1]))
		print('Transaction Rollback!!!')
		if cursor1 != None:
			cursor1.close()
		cnx.close()		
# ---------------------------------------------------------
# Completed Transaction
# ---------------------------------------------------------
	if updated:
		#move to processed
		try:
			dir_processed =  db_conf['dir_stcm'] + '\\suggestion'  + "\\" + db_conf['dir_processed']
			file_processed = dir_processed + os.path.basename(fcsv)
			os.rename(fcsv, file_processed)
			print('Finished MOVING _suggestion.csv files')
			updated = True
		except:
			updated = False
			err = sys.exc_info()
			print("Function = {0}, Error = {1}, {2}".format("update_stcm", err[0], err[1]))

		if updated and i>0:
			print("Generating new stcm csv...")
			try:

				#rename old stcm
				fstcm = db_conf['dir_stcm'] + '\\' + os.path.basename(fcsv).replace('_suggestion', '')
				os.rename(fstcm,  fstcm.replace('.csv', '_old.csv'))
				print('Renamed the stcm file')

				#generate new stcm
				dir_sql = os.getcwd() + '\\sql_scripts\\'
				fname = dir_sql + '3h_generate_new_stcm.sql'

				query = mapping_util.parse_queries_file(fname)[0]
				ret = export_csv(query, os.path.basename(fstcm).replace('.csv', ''), fstcm, debug)			

			except:
				updated = False
				err = sys.exc_info()
				print("Function = {0}, Error = {1}, {2}".format("update_stcm", err[0], err[1]))

		return(updated)	

# ---------------------------------------------------------
# MAIN PROGRAM
# ---------------------------------------------------------
def main():
	ret = True
	
	try:
		(ret, dir_study, db_conf, debug) = mapping_util.get_parameters()
		if ret == True and dir_study != '':
			vocabulary_schema = db_conf['vocabulary_schema']
			database_type = db_conf['database_type']
			dir_sql = os.getcwd() + '\\sql_scripts\\'
			dir_sql_processed = os.getcwd() + '\\sql_scripts' + db_conf['dir_processed']
			dir_voc = db_conf['dir_voc'] + "\\"
			dir_voc_processed = db_conf['dir_voc'] + db_conf['dir_processed']
			dir_stcm = db_conf['dir_stcm'] + "\\"	
# ---------------------------------------------------------
# Drop vocabularies tables - Parallel execution of queries in the file - Ask the user for DROP confirmation
# ---------------------------------------------------------
			drop_tbls = input('Are you sure you want to DROP all the CDM vocabulary tables (y/n):') 
			while drop_tbls.lower() not in ['y', 'n', 'yes', 'no']:
				drop_tbls = input('I did not understand that. Are you sure you want to DROP all the CDM vocabulary tables (y/n):') 
			if drop_tbls.lower() in ['y', 'yes']:
				fname = dir_sql + '3a_cdm_drop_vocabulary.sql'
				print('Calling ' + fname + ' ...')
				ret = mapping_util.execute_sql_file_parallel(db_conf, fname, False)
# ---------------------------------------------------------
# Create vocabularies tables - Parallel execution of queries in the file - Ask the user for CREATE/LOAD confirmation
# ---------------------------------------------------------
			if ret == True:
				load_tbls = input('Are you sure you want to CREATE/LOAD all the vocabulary tables (y/n):') 
				while load_tbls.lower() not in ['y', 'n', 'yes', 'no']:
					load_tbls = input('I did not understand that. Are you sure you want to CREATE/LOAD all the vocabulary tables (y/n):') 
				if load_tbls.lower() in ['y', 'yes']:
					fname = dir_sql + '3b_cdm_create_vocabulary.sql'
					print('Calling ' + fname + ' ...')
					ret = mapping_util.execute_sql_file_parallel(db_conf, fname, False)
# ---------------------------------------------------------
# Load vocabularies tables - Parallel execution
# ---------------------------------------------------------
					if ret == True:
						tbl_cdm_voc = [tbl for tbl in db_conf['tbl_cdm_voc']]
						file_list = [[dir_voc + tbl + '.csv'] for tbl in tbl_cdm_voc]
						if not os.path.exists(dir_voc_processed):
							os.makedirs(dir_voc_processed)
						ret = mapping_util.load_files_parallel(db_conf, vocabulary_schema, tbl_cdm_voc, file_list, dir_voc_processed)
						if ret == True:
							print('Finished loading cdm vocabulary.')
# ---------------------------------------------------------
# Create vocabularies PK, indexes - Parallel execution
# ---------------------------------------------------------
			if ret == True:
				load_tbls = input('Are you sure you want to CREATE PK/IDXs for all the vocabulary tables (y/n):') 
				while load_tbls.lower() not in ['y', 'n', 'yes', 'no']:
					load_tbls = input('I did not understand that. Are you sure you want to CREATE PK/IDXs for all the vocabulary tables (y/n):') 
				if load_tbls.lower() in ['y', 'yes']:
					print('Build PKs and IDXs ...')
					sql_file_list = sorted(glob.iglob(dir_sql + '3c_cdm_pk_idx_*.sql'))
					ret = mapping_util.execute_sql_files_parallel(db_conf, sql_file_list, True)
# ---------------------------------------------------------
# CREATE/LOAD source_to_concept_vocab_map
# ---------------------------------------------------------
			if ret == True:
				load_tbls = input('Are you sure you want to CREATE/LOAD source_to_..._map tables (y/n):') 
				while load_tbls.lower() not in ['y', 'n', 'yes', 'no']:
					load_tbls = input('I did not understand that. Are you sure you want to CREATE/LOAD source_to_..._map tables tables (y/n):') 
				if load_tbls.lower() in ['y', 'yes']:
					csv_file_list = sorted(glob.iglob(dir_stcm + '*_STCM.csv'))
					for fname in csv_file_list:
						query = 'COPY ' + vocabulary_schema + '.source_to_concept_map FROM \'' + fname + '\' WITH DELIMITER E\',\' CSV HEADER QUOTE E\'"\'';
						ret = mapping_util.execute_query(db_conf, query, True)
						if ret == False:
							break
# ---------------------------------------------------------
# CREATE/LOAD source_to_source_vocab_map
# ---------------------------------------------------------
					if ret == True:
						fname = dir_sql + '3d_cdm_source_to_source_vocab_map.sql'
						print('Calling ' + fname + ' ...')
						ret = mapping_util.execute_multiple_queries(db_conf, fname, None, None, True, True)
# ---------------------------------------------------------
# CREATE/LOAD source_to_standard_vocab_map
# ---------------------------------------------------------
					if ret == True:
						fname = dir_sql + '3e_cdm_source_to_standard_vocab_map.sql'
						print('Calling ' + fname + ' ...')
						ret = mapping_util.execute_multiple_queries(db_conf, fname, None, None, True, True)
						if ret == True:
							print('Finished CDM vocabularies processing')                        
# ---------------------------------------------------------
# CHECK STCM 
# ---------------------------------------------------------
			if ret == True:
				load_tbls = input('Are you sure you want to CHECKING ALL STCMs (y/n):') 
				while load_tbls.lower() not in ['y', 'n', 'yes', 'no']:
					load_tbls = input('I did not understand that. Are you sure you want to CHECKING ALL STCMs (y/n):') 
				if load_tbls.lower() in ['y', 'yes']:
					fname = dir_sql + '3f_check_stcm.sql'
					print('Calling ' + fname + ' ...')
					for fcsv in glob.iglob(dir_stcm + '*_STCM.csv'):
						stcm = os.path.basename(fcsv).replace('.csv', '')
						ret = check_stcm(fname, stcm, False)
						if ret == False:
							break
					if ret == True:
						print('Finished checking ALL STCMs.')
# ---------------------------------------------------------
# UPDATE STCM 
# ---------------------------------------------------------
			if ret == True:
				found = False
			
				for fcsv in glob.iglob(dir_stcm + "suggestion\\" + '*_suggestion.csv'):
					found = True
					break
		
				if found == True:
					load_tbls = input('Are you sure you want to update stcm (y/n):') 
					while load_tbls.lower() not in ['y', 'n', 'yes', 'no']:
						load_tbls = input('I did not understand that. Are you sure you want to update stcm (y/n):') 
					if load_tbls.lower() in ['y', 'yes']:
						fname = dir_sql + '3g_update_stcm.sql'
						print('Calling ' + fname + ' ...')
						for fcsv in glob.iglob(dir_stcm + "suggestion\\" + '*_suggestion.csv'):
							ret = update_stcm(fname, fcsv, False)
							if ret == False:
								break
						if ret == True:
							print('Finished updating non-standard, invalid stcm target_concept_ids.')
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
					print('Finished MOVING code files')	
	except:
		print(str(sys.exc_info()[1]))

# ---------------------------------------------------------
# Protect entry point
# ---------------------------------------------------------
if __name__ == "__main__":
	main()

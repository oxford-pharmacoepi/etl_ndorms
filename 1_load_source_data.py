import os
import sys
import time
import glob
from datetime import datetime
import psycopg2 as sql
from importlib.machinery import SourceFileLoader

mapping_util = SourceFileLoader('mapping_util', os.path.dirname(os.path.realpath(__file__)) + '/mapping_util.py').load_module()

# ---------------------------------------------------------
def is_curation_needed_aurum(tbl_patient, tbl_observation):
	"Check if curation is necessary"
# ---------------------------------------------------------
	ret 		= True
	curation 	= False
	
	try:
		cnx = sql.connect(
			user = db_conf['username'],
			password = db_conf['password'],
			database = db_conf['database']
		)
		cursor1 = cnx.cursor()
		query1 = "SELECT 1 FROM " + tbl_patient + " WHERE acceptable = 0 OR gender in (0,3,4) OR gender is null OR yob < 1875 OR regstartdate is null LIMIT 1"
		cursor1.execute(query1);
		found = cursor1.fetchone()
		if found != None:
			curation = True
		else:
			query1 = "SELECT 1 FROM " + tbl_observation + " WHERE obsdate is null"
		cursor1.execute(query1);
		found = cursor1.fetchone()
		if found != None:
			curation = True
		cursor1.close()
		cnx.close()	
	except:
		ret = False
		err = sys.exc_info()
		print("Function = {0}, Error = {1}, {2}".format("is_curation_needed_aurum", err[0], err[1]))
	return(ret, curation)

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
			tbl_db = 'tbl_' + database_type
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
				fname = dir_sql + '1__schema_create.sql'
				print('Calling ' + fname + ' ...')
				ret = mapping_util.execute_sql_file_parallel(db_conf, fname, False)
			if ret == True:
# ---------------------------------------------------------
# Ask the user for DROP confirmation
# ---------------------------------------------------------
				qa = input('Are you sure you want to DROP all the ' + database_type.upper() + ' tables (y/n):') 
				while qa.lower() not in ['y', 'n', 'yes', 'no']:
					qa = input('I did not understand that. Are you sure you want to DROP all the ' + database_type.upper() + ' tables (y/n):') 
				if qa.lower() in ['y', 'yes']:
					fname = dir_sql + '1a_' + database_type + '_drop.sql'
					print('Calling ' + fname + ' ...')
					ret = mapping_util.execute_sql_file_parallel(db_conf, fname, False)
			if ret == True:
# ---------------------------------------------------------
# Ask the user for LOAD confirmation
# ---------------------------------------------------------
				qa = input('Are you sure you want to CREATE/LOAD all the ' + database_type.upper() + ' tables (y/n):') 
				while qa.lower() not in ['y', 'n', 'yes', 'no']:
					qa = input('I did not understand that. Are you sure you want to CREATE/LOAD all the ' + database_type.upper() + ' tables (y/n):') 
				if qa.lower() in ['y', 'yes']:
# ---------------------------------------------------------
# Create source tables
# ---------------------------------------------------------
					time1 = time.time()
					fname = dir_sql + '1b_' + database_type + '_create.sql'
					print('Calling ' + fname + ' ...')
					ret = mapping_util.execute_sql_file_parallel(db_conf, fname, False)
# ---------------------------------------------------------
# Load source data
# ---------------------------------------------------------
					if ret == True:
						dir_list_folders = [dir_source_files + tbl for tbl in db_conf[tbl_db]]
						print(dir_list_folders)
						ret = mapping_util.load_folders_parallel(db_conf, source_schema, dir_list_folders)
						if ret == True:
							task_finished = "Finished loading " + database_type.upper() + " source data in {0}".format(mapping_util.calc_time(time.time() - time1))
							print(task_finished)
# ---------------------------------------------------------
# Ask the user for PK/IDX creation confirmation
# ---------------------------------------------------------
			if ret == True:
				qa = input('Are you sure you want to CREATE PK/IDXs on all the ' + database_type.upper() + ' tables (y/n):') 
				while qa.lower() not in ['y', 'n', 'yes', 'no']:
					qa = input('Are you sure you want to CREATE PK/IDXs on all the ' + database_type.upper() + ' tables (y/n):') 
				if qa.lower() in ['y', 'yes']:
# ---------------------------------------------------------
# Build PKs & IDXs
# ---------------------------------------------------------
					time1 = time.time()
					print('Build PKs and IDXs ...')
					sql_file_list = sorted(glob.iglob(dir_sql + '1c_' + database_type + '_pk_idx*.sql'))
					print(dir_sql + '1c_' + database_type + '_pk_idx*.sql')
					print(sql_file_list)
					ret = mapping_util.execute_sql_files_parallel(db_conf, sql_file_list, True)
					if ret == True:
						task_finished = 'Finished adding PKs/indexes to ' + database_type.upper() + ' in {0}'.format(mapping_util.calc_time(time.time() - time1))
						print(task_finished)
# ---------------------------------------------------------
# Check for curation
# ---------------------------------------------------------
			if ret == True:
				qa = input('Are you sure you want to CHECK/CURATE ' + database_type.upper() + ' (y/n):') 
				while qa.lower() not in ['y', 'n', 'yes', 'no']:
					qa = input('Are you sure you want to CHECK/CURATE ' + database_type.upper() + ' (y/n):') 
				if qa.lower() in ['y', 'yes']:
					time1 = time.time()
					if database_type == 'aurum':
						idx_patient = db_conf[tbl_db].index('patient')
						idx_observation = db_conf[tbl_db].index('observation')
						(ret, curation) = is_curation_needed_aurum(tbl_db_list[idx_patient], tbl_db_list[idx_observation])
					elif database_type in ['gold', 'ons', 'ncrascr']:
						curation = True
					elif database_type[0:3].lower() == 'hes':
						curation = True
					elif database_type [0:3].lower()== 'ukb':
						curation = True
					if ret == True and curation == True:
						fname = dir_sql + '1d_' + database_type + '_curation.sql'
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
					for f in glob.iglob(dir_sql + '1*.sql'):
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

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
# Create/Recreate CDM tables? Parallel execution of queries in the file - Ask the user for DROP confirmation
# ---------------------------------------------------------
			qa = input('Are you sure you want to DROP/CREATE all the CDM tables for ONS (y/n):') 
			while qa.lower() not in ['y', 'n', 'yes', 'no']:
				qa = input('I did not understand that. Are you sure you want to DROP/CREATE all the CDM tables for ONS(y/n):') 
			if qa.lower() in ['y', 'yes']:
				fname = dir_sql + '4a_ons_cdm_drop_tbl.sql'
				print('Calling ' + fname + ' ...')
				ret = mapping_util.execute_multiple_queries(db_conf, fname, None, None, True, debug)
				if ret == True:
					fname = dir_sql + '4b_ons_OMOPCDM_death_ddl.sql'
					print('Calling ' + fname + ' ...')
					ret = mapping_util.execute_sql_file_parallel(db_conf, fname, False, False)
# ---------------------------------------------------------
# mapping ONS_death to CDM Death_ONS
# ---------------------------------------------------------
			qa = input('Do you want to map the ' + database_type.upper() + ' data to OMOP CDM (y/n):') 
			while qa.lower() not in ['y', 'n', 'yes', 'no']:
				qa = input('I did not understand that. Are you sure you want to DROP/CREATE all the CDM tables (y/n):') 
			if qa.lower() in ['y', 'yes']:
				fname = dir_sql + '4c_ons_map_tbl_death_ons.sql'
				print('Calling ' + fname + ' ...')
				ret = mapping_util.execute_sql_file_parallel(db_conf, fname, False)
# ---------------------------------------------------------
# Update Death from Death_ONS
# ---------------------------------------------------------
#				if ret == True:
			qa = input('Do you want to update Death from Death_ONS (y/n):') 
			while qa.lower() not in ['y', 'n', 'yes', 'no']:
				qa = input('I did not understand that. Are you sure you want to update Death from Death_ONS (y/n):') 
			if qa.lower() in ['y', 'yes']:
				fname = dir_sql + '4d_ons_map_tbl_death.sql'
				print('Calling ' + fname + ' ...')
				ret = mapping_util.execute_sql_file_parallel(db_conf, fname, False)
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
					for f in glob.iglob(dir_sql + '4*.sql'):
						file_processed = dir_sql_processed + os.path.basename(f)
						print(os.path.basename(f))
						print(file_processed)
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
	
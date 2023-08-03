import os
import sys
import time
import glob
from importlib import import_module
from importlib.machinery import SourceFileLoader

mapping_util = SourceFileLoader('mapping_util', os.path.dirname(os.path.realpath(__file__)) + '/mapping_util.py').load_module()
db_conf = import_module('__postgres_db_conf', os.getcwd() + '\\__postgres_db_conf.py').db_conf
log = import_module('write_log', os.getcwd() + '\\write_log.py').Log('7_count_cdm_records')

# ---------------------------------------------------------
# MAIN PROGRAM
# ---------------------------------------------------------
def main():
	ret = True
	
	try:
		database_type = db_conf['database_type']
		target_schema = db_conf['target_schema']
		study_directory = db_conf['dir_study']
		dir_code = study_directory + "code\\sql_scripts\\"
# ---------------------------------------------------------
# Count records per table
# ---------------------------------------------------------
		rec_tbl = input('Are you sure you want to build the _RECORDS table (y/n):') 
		while rec_tbl.lower() not in ['y', 'n', 'yes', 'no']:
			rec_tbl = input('I did not understand that. Are you sure you want to build the _RECORDS table (y/n):') 
		if rec_tbl.lower() in ['y', 'yes']:
			time1 = time.time()
			tbl_list_count = [target_schema + "." + tbl for tbl in db_conf['tbl_cdm']] #if tbl not in ('practice', 'staff')]
			tbl_list_count.extend([target_schema + "." + tbl for tbl in db_conf['tbl_cdm_voc']])
			ret = mapping_util.get_table_count_parallel(tbl_list_count, target_schema + '._records')
			if ret == True:
				msg = 'Finished counting on ' + database_type.upper() + ' data in ' + mapping_util.calc_time(time.time() - time1) + '\n'
				log.log_message(msg)
	except:
		log.log_message(str(sys.exc_info()[1]))
# ---------------------------------------------------------
# Protect entry point
# ---------------------------------------------------------
if __name__ == "__main__":
	main()

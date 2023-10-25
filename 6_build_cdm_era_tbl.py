import os
import sys
import time
import glob
from importlib import import_module
from importlib.machinery import SourceFileLoader

mapping_util = SourceFileLoader('mapping_util', os.path.dirname(os.path.realpath(__file__)) + '/mapping_util.py').load_module()
db_conf = import_module('__postgres_db_conf', os.getcwd() + '\\__postgres_db_conf.py').db_conf
log = import_module('write_log', os.getcwd() + '\\write_log.py').Log('6_build_cdm_era_tbl')

# ---------------------------------------------------------
# MAIN PROGRAM
# ---------------------------------------------------------
def main():
	ret = True
	
	try:
		database_type = db_conf['database_type']
		target_schema = db_conf['target_schema']
		dir_code = os.getcwd() + "\\sql_scripts\\"
# ---------------------------------------------------------
# Create ERA tables
# ---------------------------------------------------------
		era_tbls = input('Are you sure you want to create the ERA tables (y/n):') 
		while era_tbls.lower() not in ['y', 'n', 'yes', 'no']:
			era_tbls = input('I did not understand that. Are you sure you want to create the era tables (y/n):') 
		if era_tbls.lower() in ['y', 'yes']:
			time1 = time.time()
			log.log_message('Create ERA tables ...')
			sql_file_list = sorted(glob.iglob(dir_code + '6a_cdm_era_*.sql'))
			ret = mapping_util.execute_sql_files_parallel(sql_file_list, True)
			if ret == True:
				msg = 'All ERA tables built on ' + database_type.upper() + ' in ' + mapping_util.calc_time(time.time() - time1)
				log.log_message(msg)
	except:
		log.log_message(str(sys.exc_info()[1]))

# ---------------------------------------------------------
# Protect entry point
# ---------------------------------------------------------
if __name__ == "__main__":
	main()

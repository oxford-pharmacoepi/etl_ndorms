import os
import sys
import time
import glob
from importlib.machinery import SourceFileLoader

mapping_util = SourceFileLoader('mapping_util', os.path.dirname(os.path.realpath(__file__)) + '/mapping_util.py').load_module()

# ---------------------------------------------------------
# MAIN PROGRAM
# ---------------------------------------------------------
def main():
	ret = True
	
	try:
		(ret, dir_study, db_conf, debug) = mapping_util.get_parameters()
		if ret == True and dir_study != '':
			database_type = db_conf['database_type']
			target_schema = db_conf['target_schema']
			dir_sql = os.getcwd() + "\\sql_scripts\\"
# ---------------------------------------------------------
# Create ERA tables
# ---------------------------------------------------------
			qa = input('Are you sure you want to create the ERA tables (y/n):') 
			while qa.lower() not in ['y', 'n', 'yes', 'no']:
				qa = input('I did not understand that. Are you sure you want to create the era tables (y/n):') 
			if qa.lower() in ['y', 'yes']:
				time1 = time.time()
				print('Create ERA tables ...')
				sql_file_list = sorted(glob.iglob(dir_sql + '6a_cdm_era_*.sql'))
				ret = mapping_util.execute_sql_files_parallel(db_conf, sql_file_list, True, False)
				if ret == True:
					msg = 'All ERA tables built on ' + database_type.upper() + ' in ' + mapping_util.calc_time(time.time() - time1)
					print(msg)
	except:
		print(str(sys.exc_info()[1]))

# ---------------------------------------------------------
# Protect entry point
# ---------------------------------------------------------
if __name__ == "__main__":
	main()

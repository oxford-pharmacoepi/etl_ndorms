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
# ---------------------------------------------------------
# Count records per table
# ---------------------------------------------------------
			qa = input('Are you sure you want to build the _RECORDS table (y/n):') 
			while qa.lower() not in ['y', 'n', 'yes', 'no']:
				qa = input('I did not understand that. Are you sure you want to build the _RECORDS table (y/n):') 
			if qa.lower() in ['y', 'yes']:
				time1 = time.time()
				ret = mapping_util.execute_query(db_conf, 'drop table if exists ' + target_schema + '._records CASCADE;', debug = False)
				if ret == True:
					ret = mapping_util.execute_query(db_conf, 'create table ' + target_schema + '._records (tbl_name varchar(25) NOT NULL, total_records bigint DEFAULT 0 )TABLESPACE pg_default;', debug = False)	
					if ret == True:
						tbl_list_count = [target_schema + "." + tbl for tbl in db_conf['tbl_cdm']]
						tbl_list_count.extend([target_schema + "." + tbl for tbl in db_conf['tbl_cdm_voc']])
						ret = mapping_util.get_table_count_parallel(db_conf, tbl_list_count, target_schema + '._records')
						if ret == True:
							msg = 'Finished counting on ' + database_type.upper() + ' data in ' + mapping_util.calc_time(time.time() - time1) + '\n'
							print(msg)
	except:
		print(str(sys.exc_info()[1]))
# ---------------------------------------------------------
# Protect entry point
# ---------------------------------------------------------
if __name__ == "__main__":
	main()

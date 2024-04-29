#--------------------------------------------------------------
# Author = A. Delmestri
# Version = 1.0
# Merge linked databases
# -------------------------------------------------------------
import subprocess
import sys
import time
import os
from datetime import datetime
#from importlib import import_module
import psycopg2 as sql
from importlib.machinery import SourceFileLoader

mapping_util = SourceFileLoader('mapping_util', os.path.dirname(os.path.realpath(__file__)) + '/mapping_util.py').load_module()

# ---------------------------------------------------------
# MAIN PROGRAM
# ---------------------------------------------------------
def main():
	ret = True
	cnx = None
	
	if len(sys.argv) < 2:
		print("Please enter the study directory as a parameter:")
	elif len(sys.argv) == 2:
		(ret, dir_study, db_conf, debug) = mapping_util.get_parameters()
		if ret == True and dir_study != '':
			time0 = time.time()
# ---------------------------------------------------------
# Connect to db
# ---------------------------------------------------------
			database = db_conf['database']
			cnx = sql.connect(
				user=db_conf['username'],
				password=db_conf['password'],
				database=database
			)
			schema1 = db_conf['target_schema_to_link'];	#public_old
			schema2 = db_conf['target_schema']; 		#public_hesop
			schema3 = 'public';
			dir_sql = os.getcwd() + "\\sql_scripts\\"
			cursor1 = cnx.cursor()
			query_str = "CREATE SCHEMA IF NOT EXISTS " + schema3;
			cursor1.execute(query_str)
			procedure_name = "public.merge_db_linked"
#			query_str = "DROP PROCEDURE IF EXISTS " + procedure_name + "(IN schema1 text, IN schema2, IN schema3)";
#			cursor1.execute(query_str)
			fname = dir_sql + 'merge_db_linked.sql'
			query_str = open(fname).read()
			print(query_str)
			print('Creating ' + procedure_name + ' ...')
			cursor1.execute(query_str)
			print('Calling ' + procedure_name + ' ...')
			cursor1.execute("CALL " + procedure_name + "(%s, %s, %s);", (schema1, schema2, schema3))
			cursor1.execute("COMMIT")
			process_finished = "{0} completed in {1}".format(os.path.basename(__file__), mapping_util.calc_time(time.time() - time0))
			print(process_finished)
# ---------------------------------------------------------
# Protect entry point
# ---------------------------------------------------------
if __name__ == "__main__":
	main()
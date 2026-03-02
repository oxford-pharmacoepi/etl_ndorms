import os
import sys
import glob
import time
import datetime
import psycopg2 as sql
from importlib.machinery import SourceFileLoader

mapping_util = SourceFileLoader('mapping_util', os.path.dirname(os.path.realpath(__file__)) + '/mapping_util.py').load_module()

# ---------------------------------------------------------
# Update Death from Death_ONS
# ---------------------------------------------------------
def updatefromDeathONS():

	ret = True
	dir_sql = os.getcwd() + '\\sql_scripts\\'

	try:
		cnx = sql.connect(
			user=db_conf['username'],
			password=db_conf['password'],
			database=db_conf['database'],
			port=db_conf['port']
		)
		cnx.autocommit = False
		cursor1 = cnx.cursor()
#################
##Before update: show the count in {target_schema_to_link}.Death
#################
		print('----- Before Update -----')
		cursor1.execute('select count(*) from ' + db_conf['target_schema_to_link']  + '.death')
		death_n = cursor1.fetchone()[0]
		print(db_conf['target_schema_to_link']  + '.death row count: ' + str(death_n))
		
#check if _patid_deleted exists
		query1 = 'SELECT to_regclass(\'' + db_conf['target_schema_to_link'] + '._patid_deleted\')';
		cursor1.execute(query1)
		present = cursor1.fetchone()[0]
		if present == None:
			print('_patid_deleted doesn\'t exist')
			fname = dir_sql + '4d_ons_insert_tbl_death.sql'
		else:
			print('_patid_deleted exists')
			fname = dir_sql + '4d_ons_insert_tbl_death_ex_patid_del.sql'
#insert	death_ons in death		
		print('Calling ' + fname + ' ...')
		queries = mapping_util.parse_queries_file(db_conf, fname)
		cursor1.execute(queries[0]);
		insert_death_n = cursor1.fetchone()[0]
		print('INSERT ' + str(insert_death_n) + ' row(s)')
			
#update death from death_ond	
		up_death_fname = dir_sql + '4d_ons_update_tbl_death.sql'
		print('Calling ' + up_death_fname + ' ...')
		queries2 = mapping_util.parse_queries_file(db_conf, up_death_fname)
		cursor1.execute(queries2[0]);
		update_death_n = cursor1.fetchone()[0]
		print('UPDATE ' + str(update_death_n) + ' row(s)')

#update observation_period
		up_op_fname = dir_sql + '4d_ons_update_tbl_observation_period.sql'
		print('Calling ' + up_op_fname + ' ...')
		queries3 = mapping_util.parse_queries_file(db_conf, up_op_fname)
		cursor1.execute(queries3[0]);
		update_op_np = cursor1.fetchone()[0]
		print('UPDATE ' + str(update_op_np) + ' row(s)')

## insert and update are in a single transaction
		cnx.commit()
		
################
##After update: show the count in {target_schema_to_link}.Death 
################
		print('----- After Update -----')
		cursor1.execute('select count(*) from ' + db_conf['target_schema_to_link']  + '.death')
		new_death_n = cursor1.fetchone()[0]
		print(db_conf['target_schema_to_link']  + '.death row count: ' + str(new_death_n))
		
		cursor1.close()
		cursor1 = None
		cnx.close()
		
	except:
		ret = False
		err = sys.exc_info()
		print("Function = {0}, Error = {1}, {2}".format("updatefromDeathONS", err[0], err[1]))
		print('Transaction Rollback!!!')
		if cursor1 != None:
			cursor1.close()
		cnx.close()
	return(ret)	
# ---------------------------------------------------------
# MAIN PROGRAM
# ---------------------------------------------------------
def main():
	ret = True
	cnx = None
	global db_conf
	
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
			if ret == True:
				qa = input('Do you want to map the ' + database_type.upper() + ' data to OMOP CDM (y/n):') 
				while qa.lower() not in ['y', 'n', 'yes', 'no']:
					qa = input('I did not understand that. Are you sure you want to map the ' + database_type.upper() + ' data to OMOP CDM (y/n):') 
				if qa.lower() in ['y', 'yes']:
					fname = dir_sql + '4c_ons_map_tbl_death_ons.sql'
					print('Calling ' + fname + ' ...')
#					ret = mapping_util.execute_sql_file_parallel(db_conf, fname, False)
					ret = mapping_util.execute_multiple_queries(db_conf, fname, None, None, True, debug, False)
# ---------------------------------------------------------
# Update Death from Death_ONS
# ---------------------------------------------------------
			if ret == True:
				qa = input('Do you want to update Death and Observation Period from Death_ONS (y/n):') 
				while qa.lower() not in ['y', 'n', 'yes', 'no']:
					qa = input('I did not understand that. Are you sure you want to update Death and Observation Period from Death_ONS (y/n):') 
				if qa.lower() in ['y', 'yes']:			
					ret = updatefromDeathONS()
# ---------------------------------------------------------
# Report total time
# ---------------------------------------------------------
			if ret == True:
				process_finished = "{0} completed in {1}".format(os.path.basename(__file__), mapping_util.calc_time(time.time() - time0))
				print(process_finished)
# ---------------------------------------------------------
# Move CODE to the processed directory?
# ---------------------------------------------------------
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
	
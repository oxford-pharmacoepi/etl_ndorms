import os
import time
import sys
import glob
from importlib.machinery import SourceFileLoader

mapping_util = SourceFileLoader('mapping_util', os.path.dirname(os.path.realpath(__file__)) + '/mapping_util.py').load_module()

# ---------------------------------------------------------
def build_fk(dir_code): 
# Build FK in parallel when possible
# ---------------------------------------------------------
	ret = True

	try:
		plist = []
		plist.append(dir_code + "5b_cdm_fk_care_site__concept.sql")
		plist.append(dir_code + "5b_cdm_fk_person__provider.sql")
		ret = mapping_util.execute_sql_files_parallel(db_conf, plist, True)
		if ret == True:
			plist.clear()
			plist.append(dir_code + "5b_cdm_fk_care_site__location.sql")
			plist.append(dir_code + "5b_cdm_fk_provider__concept.sql")
			plist.append(dir_code + "5b_cdm_fk_observation_period__person.sql")
			ret = mapping_util.execute_sql_files_parallel(db_conf, plist, True)
		if ret == True:
			plist.clear()
			plist.append(dir_code + "5b_cdm_fk_person__location.sql")
			plist.append(dir_code + "5b_cdm_fk_provider__care_site.sql")
			plist.append(dir_code + "5b_cdm_fk_observation_period__concept.sql")
			ret = mapping_util.execute_sql_files_parallel(db_conf, plist, True)
		if ret == True:
			plist.clear()
			plist.append(dir_code + "5b_cdm_fk_person__care_site.sql")
			plist.append(dir_code + "5b_cdm_fk_death__concept.sql")
			ret = mapping_util.execute_sql_files_parallel(db_conf, plist, True)
		if ret == True:
			plist.clear()
			plist.append(dir_code + "5b_cdm_fk_visit_occurrence__care_site.sql")
			plist.append(dir_code + "5b_cdm_fk_death__person.sql")
			plist.append(dir_code + "5b_cdm_fk_metadata__concept.sql")
			ret = mapping_util.execute_sql_files_parallel(db_conf, plist, True)
		if ret == True:
			plist.clear()
			plist.append(dir_code + "5b_cdm_fk_person__concept.sql")
			plist.append(dir_code + "5b_cdm_fk_visit_detail__care_site.sql")
			ret = mapping_util.execute_sql_files_parallel(db_conf, plist, True)
		if ret == True:
			sql_file_list1 = sorted(glob.iglob(dir_code + '5b_cdm_fk_*.sql'))
			sql_file_list2 = sorted(glob.iglob(dir_code + '5b' + db_conf['cdm_version'][2] + '_cdm_fk_*.sql'))
			list1 = ['condition_occurrence','device_exposure','drug_exposure','measurement','observation','procedure_occurrence','visit_detail','visit_occurrence']
			list2 = ['concept','person','provider','visit_detail','visit_occurrence']
			for i in range(len(list1)):
				plist.clear()
				for j in range(len(list2)):
					fname = dir_code + '5b_cdm_fk_' + list1[j] + '__' + list2[j] + '.sql'
					if fname in sql_file_list1:
						plist.append(fname)
					else:
						fname = dir_code + '5b' + db_conf['cdm_version'][2] + '_cdm_fk_' + list1[j] + '__' + list2[j] + '.sql'
						if fname in sql_file_list2:
							plist.append(fname)
				if plist != []:
					ret = mapping_util.execute_sql_files_parallel(db_conf, plist, True)
					if ret == False:
						break
					plist.clear()
				list1.append(list1.pop(0))
		if ret == True and db_conf['cdm_version'] == '5.4':
			fname = dir_code + "5c4_cdm_fk.sql"
			ret = mapping_util.execute_multiple_queries(db_conf, fname, None, None, True, True)
	except:
		ret = False
		err = sys.exc_info()
		print("Function = {0}, Error = {1}, {2}".format("build_fk", err[0], err[1]))
	return(ret)	

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
			dir_sql = os.getcwd() + "\\sql_scripts\\"
			processed_folder = dir_sql + "processed\\"
			if not os.path.exists(processed_folder):
				os.makedirs(processed_folder)
# ---------------------------------------------------------
# Build PKs & IDXs
# ---------------------------------------------------------
			qa = input('Are you sure you want to CREATE PK/IDX on all cdm tables (y/n):') 
			while qa.lower() not in ['y', 'n', 'yes', 'no']:
				qa = input('I did not understand that. Are you sure you want to CREATE PK/IDX on all cdm tables (y/n):') 
			if qa.lower() in ['y', 'yes']:
				print('Build PKs and IDXs ...')
				sql_file_list = sorted(glob.iglob(dir_sql + '5a_cdm_pk_idx_*.sql'))
				if ret == True:
					sql_file_list.append(dir_sql + '5a' + db_conf['cdm_version'][2] + '_cdm_pk_idx_*.sql')
				ret = mapping_util.execute_sql_files_parallel(db_conf, sql_file_list, True)
# ---------------------------------------------------------
# Build FK
# ---------------------------------------------------------
			if ret == True:
				qa = input('Are you sure you want to CREATE FK on all cdm tables (y/n):') 
				while qa.lower() not in ['y', 'n', 'yes', 'no']:
					qa = input('I did not understand that. Are you sure you want to CREATE FK on all cdm tables (y/n):') 
				if qa.lower() in ['y', 'yes']:
					print('Build FKs ...')
					ret = build_fk(dir_sql)
					if ret == True:
						print('Finished building FK')	
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
	
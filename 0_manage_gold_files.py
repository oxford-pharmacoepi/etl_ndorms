#--------------------------------------------------------------
# Author = A. Delmestri
# Version = 1.0
# Manage GOLD flat files
# -------------------------------------------------------------
import subprocess
import sys
import time
import os
import glob
from importlib.machinery import SourceFileLoader
#sys.path.append(os.path.join(os.path.dirname(__file__), '..'))
# ---------------------------------------------------------
mapping_util = SourceFileLoader('mapping_util', os.path.dirname(os.path.realpath(__file__)) + '/mapping_util.py').load_module()
# ---------------------------------------------------------
def sort_dirs(dir_study, dir_downloaded, dir_data):
	"Create all the necessary directories"
# ---------------------------------------------------------
	ret 		= True
	file_list 	= []
	
	try:
		print("sort_dirs 1")
		if not os.path.exists(dir_downloaded):
			print("Directory {0} does not exist: no data were downloaded".format(dir_downloaded))
			ret = False
		else:
			folder_processed = dir_downloaded + 'processed\\'
			if not os.path.exists(folder_processed):
				os.makedirs(folder_processed)
# ---------------------------------------------------------
# Create data directory if does not exist
# ---------------------------------------------------------
			if not os.path.exists(dir_data):
				os.makedirs(dir_data)
			dir_list_data = [dir_data + tbl + "\\" for tbl in db_conf['tbl_gold']]
			for folder in dir_list_data:
				if not os.path.exists(folder):
					os.makedirs(folder)
				folder_processed = folder + 'processed\\'
				if not os.path.exists(folder_processed):
					os.makedirs(folder_processed)
# ---------------------------------------------------------
# Create other files directories
# ---------------------------------------------------------
			dir_list_data = [dir_study + tbl + "\\" for tbl in db_conf['tbl_cprd']]
			for folder in dir_list_data:
				if not os.path.exists(folder):
					os.makedirs(folder)
				if folder in ('denominators', 'lookups'):
					folder_processed = folder + 'processed\\'
					if not os.path.exists(folder_processed):
						os.makedirs(folder_processed)
		print("sort_dirs 2")
	except:
		ret = False
		err = sys.exc_info()
		print("Function = {0}, Error = {1}, {2}".format("sort_dirs", err[0], err[1]))
	return(ret)

# ---------------------------------------------------------
# MAIN PROGRAM
# ---------------------------------------------------------
def main():
	ret = True
	global db_conf
	
	try:
# ---------------------------------------------------------
# Define directories
# ---------------------------------------------------------
		(ret, dir_study, db_conf, debug) = mapping_util.get_parameters()
		if ret == True and dir_study != '':
			dir_downloaded = dir_study + '_downloaded\\'
			dir_data = dir_study + 'data\\'
# ---------------------------------------------------------
# Create all necessary folders
# ---------------------------------------------------------
			ret = sort_dirs(dir_study, dir_downloaded, dir_data)
# ---------------------------------------------------------
# Unzip files in folders
# ---------------------------------------------------------
			if ret == True:
# ---------------------------------------------------------
# 7zip command 'e'  = Extract
# 7zip command 'x'  = eXtract with full paths
				file_list = sorted(glob.iglob(dir_downloaded + '*.7z'))
				extraction_method = []
				extraction_folder = []
				for fname in file_list:
					name = os.path.splitext(os.path.basename(fname))[0].lower()
					if name in db_conf['tbl_gold']:
						extraction_method.append('x')
						extraction_folder.append(dir_data)
					elif name in db_conf['tbl_cprd']:
						extraction_method.append('x')
						extraction_folder.append(dir_study)
					else:
						extraction_method.append('e')
						for tbl in db_conf['tbl_gold']: 
							if name.startswith(tbl):
								extraction_folder.append(dir_data + tbl)
								break
				ret = mapping_util.execute_unzip_parallel(file_list, extraction_method, extraction_folder)
	except:
		print(str(sys.exc_info()[1]))
		
# ---------------------------------------------------------
# Protect entry point
# ---------------------------------------------------------
if __name__ == "__main__":
	main()

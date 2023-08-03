import os
from datetime import datetime
from importlib import import_module

db_conf	= import_module('__postgres_db_conf',os.getcwd() + '\\__postgres_db_conf.py').db_conf

class Log:
	def __init__(self, parent_op_name, db_name=db_conf['database']):
		log_dir = db_conf['dir_log']
		if not os.path.isdir(log_dir):
			os.mkdir(log_dir)
		
		self.db_dir = log_dir + '\\' + db_name
		if not os.path.isdir(self.db_dir):
			os.mkdir(self.db_dir)
		
		today = datetime.today().strftime('%Y-%m-%d')
		
		self.logfile = f'{self.db_dir}\\{today}_{os.path.splitext(parent_op_name)[0]}.log'
#		self.log_message(f'initiating {parent_op_name}...')
	
	def log_message(self, message):
		with open(self.logfile, 'a', encoding='Latin-1') as log:
			log.write(datetime.now().strftime('%Y-%m-%d %H:%M:%S') + ' - ' + message + '\n')
			print(message)

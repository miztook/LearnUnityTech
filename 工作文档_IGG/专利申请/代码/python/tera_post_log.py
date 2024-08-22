#-*- encoding=utf8 -*-

import requests,os,sys

def post_log_file(url, log_file):
	ret = requests.post(url, data=None, files=log_file)
	print('post ret = %s ' % ret)
	pass
	
def get_log_path():
	return '%s/out.log' % get_root_path()

def get_root_path():
	return os.path.dirname(os.path.abspath(__file__))

if __name__ == '__main__':
	if len(sys.argv) == 2:
		url = sys.argv[1]
		file = open('%s/out.log' % get_root_path(), 'rb')
		
		post_log_file(url, {'log_file': file})
		file.close()
		pass
	
	pass
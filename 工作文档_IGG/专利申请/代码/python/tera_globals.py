#-*- encoding=utf8 -*-

# 全局数据定义
param = None

def log(log_str):
	print('Log:[ %s ]' % log_str)
	param.file_log_handler.flush()
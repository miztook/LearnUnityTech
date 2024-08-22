#-*- encoding=utf8 -*-

import os,sys
import subprocess
import requests
import tera_globals as _G
import datetime
from ftphelper import FtpHelper
import socket
import ctypes
import os
import platform
import sys

class TeraUtility:
	_file_log = Noneb
	def __int__(self):
		pass

	
	@staticmethod
	def get_log_path():
		return '%s/out.log' % TeraUtility.get_root_path()

	@staticmethod
	def get_start_log_path():
		return '%s/Autobuild.log' % TeraUtility.get_root_path()

	@staticmethod
	def get_root_path():
		return os.path.dirname(os.path.abspath(__file__))

	@staticmethod
	def get_lock_path():
		return '%s/%s' % (TeraUtility.get_root_path(), 'tera_autobuilding.lock')

	@staticmethod
	def is_running():
		return os.path.exists(TeraUtility.get_lock_path())

	@staticmethod
	def try_start_build():
		if TeraUtility.is_running():
			_G.log('Is Running Now!')
			TeraUtility.failed_exit(True)
		else:
			file = open(TeraUtility.get_lock_path(), 'w')
			file.flush()
			file.close()
			pass
		pass

	@staticmethod
	def padding(list):
		result = ''
		if list is None or len(list) == 0:
			pass
		else:
			index = 0
			for name in list:
				if index == 0:
					result = name
				else:
					result = str('%s_%s' % (result, name))
					pass
				index += 1
				pass
			pass
		return result
	
	@staticmethod
	def execute(cmd, desc=None):
		if desc is None:
			print('execute: [{}]'.format(cmd))
		else:
			print('execute: [{}]'.format(desc))
			pass
		_G.param.file_log_handler.flush()
		
		mytask = subprocess.Popen(cmd,
		                          shell=True,
		                          stdin=subprocess.PIPE,
		                          stdout=_G.param.file_log_handler.fileno(),
		                          stderr=_G.param.file_log_handler.fileno())

		while mytask.poll() is None:
			pass

		print('Execute::[%s]:RetCode = [%s]' % (cmd, mytask.returncode))
		if mytask.returncode == 0:
			print('Command success')
			_G.param.file_log_handler.flush()
		else:
			print('Command failed!!!: [{}]'.format(cmd))
			TeraUtility.failed_exit()
			pass
		pass
	
	@staticmethod
	def ssh_execute(ssh_client, cmd):
		print('ssh_execute: [{}]'.format(cmd))
		stdin, stdout, stderr = ssh_client.exec_command(cmd)
		print(stdout.read())
		
		pass
	
	@staticmethod
	def zip_file(file_name, src_path, dest_path):
		from filehelper import FileHelper
		import zipfile
		
		os.chdir(src_path)
		if os.path.exists(dest_path):
			file_helper = FileHelper()
			file_helper.delete_folder(dest_path)
			del file_helper
			pass
		
		if not os.path.exists(dest_path):
			os.makedirs(dest_path)
			pass
		
		dest_name = '%s\\%s' % (dest_path, file_name)
		zip = zipfile.ZipFile(dest_name, 'w', zipfile.ZIP_DEFLATED, allowZip64=True)
		
		for dirpath, dirnames, filenames in os.walk('.\\'):
			for filename in filenames:
				full_path = os.path.join(dirpath, filename)
				print('Zip:[ %s ]' % full_path)
				zip.write(full_path)
				pass
			pass
		zip.close()
		pass
	
	@staticmethod
	def ftp_upload(upload_path, param=None, ingore=None):
		if param is None:
			print('ftp upload param is None')
			return
		
		ftp = FtpHelper(param)
		ftp.login()
		print('upload_path = %s' % upload_path)
		print('remotepath = %s' % param['remotepath'])
		ftp.create_dir(param['remotepath'])
		ftp.upload_files(upload_path, param['remotepath'], ingore)
		ftp.quit()
		pass
	
	@staticmethod
	def ftp_download(local_dest_path, param=None):
		if param is None:
			print('ftp upload param is None')
			return
		
		ftp = FtpHelper(param)
		ftp.login()
		print('remotepath = %s' % param['remotepath'])
		real_remote_path = '/%s' % param['remotepath']
		ftp.download_files(local_dest_path, real_remote_path)
		ftp.quit()
		pass

	@staticmethod
	def ftp_file_exist(param=None):
		if param is None:
			print('ftp upload param is None')
			return False

		ftp = FtpHelper(param)
		ftp.login()
		print('remotepath = %s' % param['remotepath'])
		real_remote_path = '/%s' % param['remotepath']
		bRet = ftp.file_exist(real_remote_path)
		ftp.quit()
		return bRet

	@staticmethod
	def success_exit():
		TeraUtility.post_succeed(True)
		TeraUtility.__stop_build_release_lock(True)
		pass
	
	@staticmethod
	def failed_exit(is_running = False):
		TeraUtility.post_succeed(False)
		if not is_running:
			TeraUtility.__stop_build_release_lock(False)
			pass
		pass
	
	@staticmethod
	def post_succeed(succeed=False):
		file = open('%s/out.log' % TeraUtility.get_root_path(), 'rb')
		build_id = _G.param.input_param.build_Id
		if succeed:
			ftp_package_url = _G.param.ftp_backup_package_param.fullpath
			app_http_path = 'ftp://%s/%s/%s' % (ftp_package_url,
			                                    _G.param.input_param.platform_type,
			                                    _G.param.project_all_name)

			dsym_http_path = "#"
			if _G.param.input_param.platform_type == 'iOS':
				ftp_dsym_url = _G.param.ftp_backup_package_param.dsym_fullpath
				dsym_http_path = 'ftp://%s/%s.tar' % (ftp_dsym_url, _G.param.project_all_name)
				pass

			TeraUtility.post_http(build_id, {'log_file': file}, "1", app_http_path, dsym_http_path)
		else:
			TeraUtility.post_http(build_id, {'log_file': file}, "0")
		pass

	@staticmethod
	def post_http(build_id, log_file, succeed, app_http_path="#", dsym_path="#"):
		postdata = dict(build_id=build_id,
		                app_http_path=app_http_path,
		                dsym_path=dsym_path,
		                succeed=succeed)
		_G.log('post_http app_http_path = %s' % app_http_path)
		ret = requests.post(_G.param.post_finish_url, data=postdata, files=log_file)
		_G.log('post ret = %s ' % ret)
		pass
	
	@staticmethod
	def __stop_build_release_lock(succeed=False):
		if TeraUtility.is_running():
			print('__stop_build_release_lock')
			os.remove(TeraUtility.get_lock_path())
			pass
		
		if succeed:
			print('All Job Success')
		else:
			print('Error Stop')
			exit(-1)
			pass
		pass

	@staticmethod
	def get_now():
		return (datetime.datetime.now()).strftime('%Y-%m-%d %H:%M:%S')

	@staticmethod
	def get_timestamp():
		return (datetime.datetime.now()).strftime('%y-%m-%d-%I-%M-%S-%p')
	
	@staticmethod
	def get_build_target():
		cur_platform_type = _G.param.input_param.platform_type
		if cur_platform_type == 'iOS':
			return 'iOS'
		elif cur_platform_type == 'Android':
			return 'Android'
		else:
			return 'Win64'
		pass
	
	@staticmethod
	def modify_patch_permission_ssh(param):
		import paramiko
		ssh = paramiko.SSHClient()
		ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
		ssh.connect(param['hostpath'], 22, param['username'], param['password'])
		transport = ssh.get_transport()
		transport.set_keepalive(999999)

		cmd_str = 'chmod -R 755 /home/lantu/www/meteorite%s' % param['remotepath']
		TeraUtility.ssh_execute(ssh, cmd_str)
		ssh.close()
		pass
	
	@staticmethod
	def get_ip():
		# 获取本机计算机名称
		hostname = socket.gethostname()
		# 获取本机ip
		ip = socket.gethostbyname(hostname)
		return ip

	@staticmethod
	def get_free_space(folder):
		result = 0.0
		if platform.system() == 'Windows':
			free_bytes = ctypes.c_ulonglong(0)
			ctypes.windll.kernel32.GetDiskFreeSpaceExW(ctypes.c_wchar_p(folder), None, None, ctypes.pointer(free_bytes))
			result = free_bytes.value / 1024 / 1024 / 1024
		else:
			st = os.statvfs(folder)
			result = st.f_bavail * st.f_frsize / 1024 / 1024
		return result

	# Class TeraUtility End
	pass
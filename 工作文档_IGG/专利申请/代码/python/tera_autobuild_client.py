# -*- encoding=utf8 -*-

import os
from svnhelper import SvnHelper
from filehelper import FileHelper
import tera_globals as _G
from tera_utility import TeraUtility
import pandas as pd
from tera_config import *

###########################################################
#                       客户端打包模块
###########################################################
class AutobuildClient:
	
	def __init__(self):
		pass
	
	@staticmethod
	def start():
		_G.log('Autobuild_M1Client::Start At %s' % TeraUtility.get_now())
		platform_type = _G.param.input_param.platform_type
		
		
		if 'iOS' == platform_type:
			# iOS Call ssh MacOS builder
			AutobuildClient.build_m1client_ios()
			pass
		else:
			# Windows & Android
			AutobuildClient.checkout_m1client()
			# Set Base Version
			AutobuildClient.set_client_base_version()
			# Set Complatform
			AutobuildClient.set_complatform()
			# Set Macro Definition
			AutobuildClient.set_macro_definition()
			# Prebuild
			AutobuildClient.prebuild()

			# Build Client
			if platform_type == 'Android':
				AutobuildClient.select_android_api()
				AutobuildClient.build_m1client_android()
				pass
			else:
				AutobuildClient.build_m1client_windows()
				pass
			pass
	
		pass
	
	# 更新 M1Client客户端 工程
	@staticmethod
	def checkout_m1client():
		local_dest_path = '%s\\%s' % (_G.param.m1client_path, _G.param.input_param.branch_path)
		cur_client_param, cur_revision = _G.param.get_cur_client_svn_param()
		svn = SvnHelper(cur_client_param)
		
		_G.log('local path = %s' % local_dest_path)
		if os.path.exists(local_dest_path):
			svn.cleanup()
			svn.revert()
			pass
		else:
			os.makedirs(local_dest_path)
			pass
		
		svn.checkout(None if cur_revision == '0' else cur_revision)
		svn.revert()
		del svn
		pass
	
	# 设置基础版本号 更新基础版办号
	@staticmethod
	def set_client_base_version():
		_G.log('Set Client Base Version')
		base_version = _G.param.input_param.version_param.base_version
		unity_path = _G.param.unity_param.real_path
		m1client_path = _G.param.m1client_path
		branch_path = _G.param.input_param.branch_path
		build_target = TeraUtility.get_build_target()
		
		untiy_run = '%s -quit -nographics -projectPath %s\\%s\\UnityProject -project-Tera' % (unity_path,
		                                                                                      m1client_path,
		                                                                                      branch_path)
		
		build_target_cmd_str = '%s -buildTarget %s -batchmode' % (untiy_run, build_target)
		set_base_ver_cmd_str = '%s -executeMethod BuildTools.SetClientBaseVersion %s' % (build_target_cmd_str, base_version)
		
		TeraUtility.execute(set_base_ver_cmd_str)
		_G.log('Set Client Base Version success')
		pass
	
	@staticmethod
	def set_complatform():
		_G.log('Set Complatform type')
		complatform = _G.param.input_param.version_param.complatform
		unity_path = _G.param.unity_param.real_path
		m1client_path = _G.param.m1client_path
		branch_path = _G.param.input_param.branch_path
		build_target = TeraUtility.get_build_target()
		
		untiy_run = '%s -quit -nographics -projectPath %s\\%s\\UnityProject -project-Tera' % (unity_path,
		                                                                                      m1client_path,
		                                                                                      branch_path)
		
		build_target_cmd_str = '%s -buildTarget %s -batchmode' % (untiy_run, build_target)
		set_complatform_cmd_str = '%s -executeMethod BuildTools.SetComplatform %s' % (build_target_cmd_str, complatform)
		
		TeraUtility.execute(set_complatform_cmd_str)
		_G.log('Set Complatform success')
		pass

	@staticmethod
	def set_macro_definition():
		_G.log('Set Macro Definition')
		unity_path = _G.param.unity_param.real_path
		m1client_path = _G.param.m1client_path
		branch_path = _G.param.input_param.branch_path
		build_target = TeraUtility.get_build_target()
		macro_definition = _G.param.get_macro_definition()
		untiy_run = '%s -quit -nographics -projectPath %s\\%s\\UnityProject -project-Tera' % (unity_path,
																							  m1client_path,
																							  branch_path)

		build_target_cmd_str = '%s -buildTarget %s -batchmode' % (untiy_run, build_target)
		set_macro_definition_cmd_str = '%s -executeMethod BuildTools.SetScriptingDefineSymbols %s' % (build_target_cmd_str, macro_definition)

		TeraUtility.execute(set_macro_definition_cmd_str)
		_G.log('Set Macro Definition success')
		pass

	@staticmethod
	def prebuild():
		_G.log('Prebuild Client')
		unity_path = _G.param.unity_param.real_path
		m1client_path = _G.param.m1client_path
		branch_path = _G.param.input_param.branch_path
		build_target = TeraUtility.get_build_target()
		untiy_run = '%s -quit -nographics -projectPath %s\\%s\\UnityProject -project-Tera' % (unity_path,
																							  m1client_path,
																							  branch_path)

		build_target_cmd_str = '%s -buildTarget %s -batchmode' % (untiy_run, build_target)
		prebuild_cmd_str = '%s -executeMethod BuildTools.PrebuildClient' % build_target_cmd_str
		TeraUtility.execute(prebuild_cmd_str)

		_G.log('Prebuild Client success')
		pass
	# @staticmethod
	# def prebuild():
	# 	_G.log('Prebuild Client')
	# 	platform_type = _G.param.input_param.platform_type
	# 	complatform = _G.param.input_param.version_param.complatform
	# 	if platform_type == 'Android' and complatform.find('cn') != 1:
	# 		m1client_path = '%s\\%s' % (_G.param.m1client_path, _G.param.input_param.branch_path)
    #
	# 		file_help = FileHelper()
	# 		src_path = '%s\\SDK\\Fabric\\3rd\\Fabric' % m1client_path
	# 		dest_path = '%s\\UnityProject\\Assets\\3rd\\Fabric' % m1client_path
	# 		file_help.copy_tree(src_path,dest_path)
    #
	# 		src_path = '%s\\SDK\\Fabric\\Plugins\\Android' % m1client_path
	# 		dest_path = '%s\\UnityProject\\Assets\\Plugins\\Android' % m1client_path
	# 		file_help.copy_tree(src_path, dest_path)
	# 		del file_help
	# 		pass
    #
	# 	_G.log('Prebuild Client success')
	# 	pass
###############################################################################################
	@staticmethod
	def build_m1client_windows():
		_G.log('Build Client Windows')
		platform_type = _G.param.input_param.platform_type
		unity_path = _G.param.unity_param.real_path
		m1client_path = _G.param.m1client_path
		branch_path = _G.param.input_param.branch_path
		build_target = TeraUtility.get_build_target()
		
		untiy_run = '%s -quit -nographics -projectPath %s\\%s\\UnityProject -project-Tera' % (unity_path,
		                                                                                      m1client_path,
		                                                                                      branch_path)
		
		method_base = '%s -executeMethod BuildTools.BuildForWindows -project-Tera' % untiy_run
		build_client_cmd_str = '%s -buildTarget %s -batchmode' % (method_base, build_target)
		
		# Clean old Package
		copy_from_path = '%s\\%s\\GameRes' % (m1client_path, branch_path)
		package_path = '%s\\%s\\Package' % (m1client_path, branch_path)
		file_help = FileHelper()
		file_help.delete_folder(package_path)

		build_client_cmd_str = '%s -buildTarget %s -batchmode %s' % (method_base, build_target, package_path)

		TeraUtility.execute(build_client_cmd_str)
		_G.log('Build Client Windows success')
		
		_G.log('Copy Client need')
		# Copy Client need
		copy_dest_path = package_path + '\\GameRes'
		copy_list = ['\\BehaviacData','\\Configs','\\Data','\\Maps','\\Audio\\GeneratedSoundBanks\\Windows','\\Video']
		
		for name in copy_list:
			file_help.copy_tree(copy_from_path + name, copy_dest_path + name, '.meta')
			pass
		
		# lua compile
		lua_compile_path = '%s\\%s\\Tools\\lua_compiler' % (m1client_path, branch_path)
		lua_compile_cmd_str = '%s\\cmd_compile.bat' % lua_compile_path
		TeraUtility.execute(lua_compile_cmd_str)
		
		src_path = '%s\\Output\\lua' % lua_compile_path
		dest_path = '%s\\Lua' % copy_dest_path
		
		file_help.copy_tree(src_path, dest_path)
		
		
		# assetbundles
		#src_path = '%s\\AssetBundles\\%s' % (copy_from_path, platform_type)
		dest_path = '%s\\AssetBundles\\%s' % (copy_dest_path, platform_type)
		
		# Download Assetbundle
		ftp_ab_usr = _G.param.ftp_backup_ab_param.username
		ftp_ab_pwd = _G.param.ftp_backup_ab_param.password
		host_url = _G.param.ftp_backup_ab_param.host_url
		remote_path = _G.param.ftp_backup_ab_param.remote_path
		base_version = _G.param.input_param.version_param.base_version
		
		ab_ftp_backup_full_path = '%s/%s/%s/%s/Base' % (remote_path, branch_path, platform_type, base_version)
		ab_ftp_download_param = {'username': ftp_ab_usr,
		                         'password': ftp_ab_pwd,
		                         'hostpath': host_url,
		                         'remotepath': ab_ftp_backup_full_path}
		TeraUtility.ftp_download(dest_path, ab_ftp_download_param)
		
		del file_help
		pass
	
	
###############################################################################################
	@staticmethod
	def build_m1client_ios():
		_G.log('build_m1client_ios')
		import paramiko
		ssh = paramiko.SSHClient()
		ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
		
		ip = _G.param.macos_param.ip
		port = _G.param.macos_param.port
		usr = _G.param.macos_param.username
		pwd = _G.param.macos_param.password
		workspace = _G.param.macos_param.workspace
		library_path = _G.param.macos_param.library_path
		
		_G.log('ip = %s' % ip)
		_G.log('port = %s' % port)
		_G.log('usr = %s' % usr)
		_G.log('pwd = %s' % pwd)
		_G.log('workspace = %s' % workspace)
		_G.log('library_path = %s ' % library_path)
		
		# Connect
		ssh.connect(ip,port,usr,pwd)
		transport = ssh.get_transport()
		transport.set_keepalive(999999)
		
		# kill running sh
		TeraUtility.ssh_execute(ssh, 'killall tera_autobuild.sh')
		TeraUtility.ssh_execute(ssh, 'killall Unity')
		
		# Chmod Permission
		cmd_str = 'chmod -R 777 %s' % workspace
		TeraUtility.ssh_execute(ssh, cmd_str)
		
		cmd_str = 'security unlock -p %s %s/Keychains/login.keychain' % (pwd,library_path)
		TeraUtility.ssh_execute(ssh, cmd_str)
		
		# Build iOS
		cmd_str = _G.param.get_build_ios_ssh_cmd_str()
		_G.log('Build iOS cmd_str = %s' % cmd_str)

		TeraUtility.ssh_execute(ssh, cmd_str)
		ssh.close()
		pass
		
	# Class AutobuildClient End
	pass
###############################################################################################

	@staticmethod
	def select_android_api():
		_G.log('Select Android Api')
		key = 'dev'
		complatform = _G.param.input_param.version_param.complatform
		if complatform.find('kakao') != -1:
			key = 'kakao'
			pass
		elif complatform.find('longtu') != -1:
			key = 'longtu'
			pass
		else:
			pass

		pd_android_api = pd.DataFrame(data=list(Content_Android_Api.values()),
		                              index=list(Content_Android_Api.keys()),
		                              columns=['level'])

		lv = pd_android_api['level'][key]
		_G.log('Android Api [Lv = %d] for %s' % (lv, complatform))

		api_src = '%s\\android-%d' % (Content_Android_All_Platforms_Path, lv)
		api_dst = '%s\\android-%d' % (Content_Android_Platforms_Path, lv)
		_G.log("api_src path = " + api_src)
		_G.log('api_dst_path = ' + api_dst)

		file_helper = FileHelper()
		file_helper.delete_folder(Content_Android_Platforms_Path)
		if os.path.exists(Content_Android_Platforms_Path) is False:
			os.makedirs(Content_Android_Platforms_Path)
			pass

		file_helper.copy_tree(api_src, api_dst)
		del file_helper
		pass


	@staticmethod
	def build_m1client_android():
		_G.log('Build Client Android')
		unity_path = _G.param.unity_param.real_path
		m1client_path = _G.param.m1client_path
		branch_path = _G.param.input_param.branch_path
		build_target = TeraUtility.get_build_target()
		project_all_name = _G.param.project_all_name
		
		package_path = '%s\\%s\\Package' % (m1client_path, branch_path)
		file_help = FileHelper()
		file_help.delete_folder(package_path)
		os.makedirs(package_path)

		res_base_path = '%s\\%s\\UnityProject\\Assets\\StreamingAssets\\res_base' % (m1client_path, branch_path)
		file_help.delete_folder(res_base_path)
		os.makedirs(res_base_path)

		fileListGenerator_path = "%s\\%s\\FileListGenerator.exe" % (m1client_path, branch_path)
		generator_filelist_cmd_str = '%s %s' % (fileListGenerator_path, res_base_path)
		TeraUtility.execute(generator_filelist_cmd_str)
		_G.log('FileListGenerator success')

		del_root_path = '%s\\%s\\UnityProject\Assets' % (m1client_path, branch_path)
		del_list = ['\\Plugins\\iOS',
					'\\Plugins\\x86',
					'\\Plugins\\x86_64',
					'\\Wwise\Deployment\\Plugins\\Windows',
					'\\Wwise\Deployment\\Plugins\\Mac',
					'\\Wwise\Deployment\\Plugins\\iOS',]
		for name in del_list:
			file_help.delete_folder(del_root_path + name)
			pass
		
		untiy_run = '%s -quit -nographics -projectPath %s\\%s\\UnityProject -project-Tera' % (unity_path,
		                                                                                      m1client_path,
		                                                                                      branch_path)
		
		build_target_cmd_str = '%s -buildTarget %s -batchmode' % (untiy_run, build_target)
		build_client_cmd_str = '%s -executeMethod BuildTools.BuildForAndroid %s %s' % (build_target_cmd_str, project_all_name, package_path)
		
		#prebuild_cmd_str = '%s -executeMethod BuildTools.FixGraphicSetting_iOS' % build_target_cmd_str
		#TeraUtility.execute(prebuild_cmd_str)
		#_G.log('Build Client Android success - FixGraphicSetting_iOS')
		
		TeraUtility.execute(build_client_cmd_str)
		_G.log('Build Client Android success')

		del file_help
		pass
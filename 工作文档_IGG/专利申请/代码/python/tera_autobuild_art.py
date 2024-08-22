# -*- encoding=utf8 -*-

import os
from svnhelper import SvnHelper
import tera_globals as _G
from tera_utility import TeraUtility
from filehelper import FileHelper

###########################################################
#                       美术资源打包模块
###########################################################
class AutobuildArt:
	def __init__(self):
		self._export_path = '%s\\%s\\TERAMobile\\Export\\AssetBundles\\%s' % (_G.param.m1res4build_path,
		                                                                      _G.param.input_param.branch_path,
		                                                                      _G.param.input_param.platform_type)
		pass
	
	@property
	def export_path(self):
		return self._export_path
	
	@staticmethod
	def start():
		_G.log('Autobuild_M1Res4Build::start')
		AutobuildArt.checkout_m1res4build()
		AutobuildArt.build_m1res4build()
		pass

	# 更新 M1Res4Build资源 工程
	@staticmethod
	def checkout_m1res4build():
		local_dest_path = '%s\\%s' % (_G.param.m1res4build_path, _G.param.input_param.branch_path)
		cur_art_param, cur_revision = _G.param.get_cur_art_svn_param()
		svn = SvnHelper(cur_art_param)
		
		if os.path.exists(local_dest_path):
			svn.cleanup()
			svn.revert()
			pass
		
		_G.log('cur_revision = %s' % cur_revision)
		svn.checkout(None if cur_revision == '0' else cur_revision)
		svn.revert()
		del svn
		pass
	
	@staticmethod
	def build_m1res4build():
		platform_type = _G.param.input_param.platform_type
		base_version = _G.param.input_param.version_param.base_version
		current_version = _G.param.input_param.version_param.current_version
		
		unity_path = _G.param.unity_param.real_path
		m1res4build_path = _G.param.m1res4build_path
		branch_path = _G.param.input_param.branch_path
		build_target = TeraUtility.get_build_target()
		check_autobuild_timestamp = '%s/____timestamp_%s' % (_G.param.tera_workspace_path, TeraUtility.get_timestamp())
		
		# _G.log('check_autobuild_timestamp = %s' % check_autobuild_timestamp)
		
		untiy_run = '%s -quit -nographics -projectPath %s\\%s\\TERAMobile' % (unity_path,
		                                                                      m1res4build_path,
		                                                                      branch_path)
		# 基础 / 增量
		if base_version == current_version:
			method_base = '%s -executeMethod BuildScript.AutoBuildBasicAssetBundle4%s' % (untiy_run, platform_type)
			build_ab_cmd_str = '%s -buildTarget %s -batchmode %s' % (method_base,
			                                                         build_target,
			                                                         check_autobuild_timestamp)
		else:
			export_path = '%s\\%s\\TERAMobile\\Export\\AssetBundles\\%s' % (_G.param.m1res4build_path,
																			_G.param.input_param.branch_path,
																			_G.param.input_param.platform_type)
			filehelper = FileHelper()
			if os.path.exists(export_path):
				filehelper.delete_folder(export_path)
				pass
			del filehelper
			os.makedirs(export_path)

			platform_type = _G.param.input_param.platform_type
			branch_path = _G.param.input_param.branch_path
			base_version = _G.param.input_param.version_param.base_version
			ftp_ab_usr = _G.param.ftp_backup_ab_param.username
			ftp_ab_pwd = _G.param.ftp_backup_ab_param.password
			ftp_ab_host_url = _G.param.ftp_backup_ab_param.host_url
			ftp_ab_remote_path = _G.param.ftp_backup_ab_param.remote_path
			ftp_ab_full_path = '%s/%s/%s/%s/Base' % (ftp_ab_remote_path, branch_path, platform_type, base_version)
			ab_ftp_download_param = {'username': ftp_ab_usr,
									 'password': ftp_ab_pwd,
									 'hostpath': ftp_ab_host_url,
									 'remotepath': ftp_ab_full_path}
			TeraUtility.ftp_download(export_path, ab_ftp_download_param)

			method_update = '%s -executeMethod BuildScript.AutoBuildUpdateBasicAssetBundle4%s' % (
			untiy_run, platform_type)
			build_ab_cmd_str = '%s -buildTarget %s -batchmode %s' % (method_update,
			                                                         build_target,
			                                                         check_autobuild_timestamp)
			pass
		
		TeraUtility.execute(build_ab_cmd_str)
		
		if os.path.exists(check_autobuild_timestamp):
			_G.log('Build AssetBundles %s success' % platform_type)
			os.remove(check_autobuild_timestamp)
		else:
			_G.log('Build AssetBundles, Unity may Crash!!!')
			TeraUtility.failed_exit()
		pass
	
	pass
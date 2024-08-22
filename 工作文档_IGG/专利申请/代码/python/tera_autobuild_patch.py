# -*- encoding=utf8 -*-


import os
from svnhelper import SvnHelper
from filehelper import FileHelper
import tera_globals as _G
from tera_utility import TeraUtility
class AutobuildPatch:
	def __init__(self):
		self._file_helper = FileHelper()
		self._platform_type = _G.param.input_param.platform_type
		self._project_all_name = _G.param.project_all_name
		self._branch_path = _G.param.input_param.branch_path
		self._base_version = _G.param.input_param.version_param.base_version
		self._current_version = _G.param.input_param.version_param.current_version
		self._last_version = _G.param.input_param.version_param.last_version
		self._complatform = _G.param.input_param.version_param.complatform
		patch_workspace_path = _G.param.patch_param.workspace_path
		patch_root_path = '%s\\patch\\%s\\%s\\%s' % (patch_workspace_path,
		                                             self._branch_path,
		                                             self._base_version,
		                                             self._platform_type)
		self._last_folder ='%s\\UpdateResource\\LastVersion' % patch_root_path
		self._current_folder = '%s\\UpdateResource\\CurrentVersion' % patch_root_path
		self._output_path = '%s\\JupGenerate' % patch_root_path
		self._packtools_path = '%s\\commandtool' % patch_workspace_path
		self._is_smallpack = _G.param.input_param.version_param.is_smallpack
		
		self._clean_path = '%s\\patch\\%s' % (patch_workspace_path, self._branch_path)
		pass
	
	
	def start(self):
		print('Patch:start')
		self.clean()

		# 更新输出路径，无论是否存在，都进行清理，上传备份时减少冗余备份时间。
		if os.path.exists(self._output_path):
			self._file_helper.delete_folder(self._output_path)
		try:
			os.makedirs(self._output_path)
		except:
			pass
		
		# 生成更新文件
		self.__generate_patch()
		
		# 上传文件 更新 ftp服务器
		ftp_patch_usr = _G.param.patch_param.username
		ftp_patch_pwd = _G.param.patch_param.password
		ftp_patch_host_url = _G.param.patch_param.host_url
		ftp_patch_remote_path = '%s/%s/%s' % (_G.param.patch_param.remote_path,
		                                      self._complatform,
		                                      self._platform_type)
		
		ftp_patch_upload_param = {'username': ftp_patch_usr,
		                          'password': ftp_patch_pwd,
		                          'hostpath': ftp_patch_host_url,
		                          'remotepath': ftp_patch_remote_path}
		
		TeraUtility.ftp_upload(self._output_path,ftp_patch_upload_param,'.manifest')
		
		# ftp 权限配置
		TeraUtility.modify_patch_permission_ssh(ftp_patch_upload_param)
		pass
	
	def clean(self):
		print('Patch:clean')
		if os.path.exists(self._clean_path):
			self._file_helper.delete_folder(self._clean_path)
		pass
	
	# 更新 M1Client客户端 工程
	def __checkout_m1client_to_path(self, parentpath, version=None, revision=None):
		svn_path = '%s/%s/GameRes' % (_G.param.svn_param.client_svn_path, self._branch_path)
		m1client_param = {'username': _G.param.svn_param.username,
		                  'password': _G.param.svn_param.password,
		                  'svnpath': svn_path,
		                  'parentpath': parentpath}
		
		svn = SvnHelper(m1client_param)
		if os.path.exists(svn_path):
			if self._current_version != self._base_version:
				svn.cleanup()
				svn.revert()
				pass
		else:
			try:
				os.makedirs(parentpath)
			except:
				pass
			pass
		
		svn.checkout(revision)
		svn.revert()
		del svn
		
		# Download Assetbundle
		ftp_ab_usr = _G.param.ftp_backup_ab_param.username
		ftp_ab_pwd = _G.param.ftp_backup_ab_param.password
		host_url = _G.param.ftp_backup_ab_param.host_url
		remote_path = _G.param.ftp_backup_ab_param.remote_path
		
		client_bundle_path = '%s\\AssetBundles\\%s' % (parentpath, self._platform_type)
		ab_ftp_backup_full_path = '%s/%s/%s/%s' % (remote_path,
		                                           self._branch_path,
		                                           self._platform_type,
		                                           self._base_version)
		ab_ftp_download_param = {'username': ftp_ab_usr,
		                         'password': ftp_ab_pwd,
		                         'hostpath': host_url,
		                         'remotepath': '%s/Base' % ab_ftp_backup_full_path}
		TeraUtility.ftp_download(client_bundle_path, ab_ftp_download_param)
		
		if version != self._base_version:
			client_ab_update_path = '%s\\Update' % client_bundle_path
			if os.path.exists(client_ab_update_path):
				self._file_helper.delete_folder(client_ab_update_path)
				pass
			
			ab_ftp_download_param = {'username': ftp_ab_usr,
			                         'password': ftp_ab_pwd,
			                         'hostpath': host_url,
			                         'remotepath': '%s/Update_%s' % (ab_ftp_backup_full_path,
			                                                         version)}
			TeraUtility.ftp_download(client_ab_update_path, ab_ftp_download_param)
			pass
		pass
		
	# 更新开始
	def __generate_patch(self):
		os.chdir(self._packtools_path)

		# 如果存在备份更新信息，下载后继续生成。
		# 更新不允许回退版本，则不备份小版本信息。

		# 更新文件备份路径 & 账户信息
		ftp_backup_patch_usr = _G.param.ftp_backup_patch_param.username
		ftp_backup_patch_pwd = _G.param.ftp_backup_patch_param.password
		ftp_backup_patch_host_url = _G.param.ftp_backup_patch_param.host_url
		ftp_backup_patch_remote_path = '%s/%s/%s/%s' % (_G.param.ftp_backup_patch_param.remote_path,
		                                                self._complatform,
		                                                self._platform_type,
		                                                self._base_version)

		# 下载 备份更新文件，以便于本次更新正常进行。
		ftp_backup_patch_download_param = {'username': ftp_backup_patch_usr,
		                                   'password': ftp_backup_patch_pwd,
		                                   'hostpath': ftp_backup_patch_host_url,
		                                   'remotepath': ftp_backup_patch_remote_path}

		# 存在备份版本信息，下载
		if TeraUtility.ftp_file_exist(ftp_backup_patch_download_param) is True:
			TeraUtility.ftp_download(self._output_path, ftp_backup_patch_download_param)


		if self._current_version == self._base_version:
			self.__generate_base()
		else:
			self.__generate_update()
			pass

		# 更新生成完成后，备份版本信息
		ftp_backup_patch_upload_param = {'username': ftp_backup_patch_usr,
		                                 'password': ftp_backup_patch_pwd,
		                                 'hostpath': ftp_backup_patch_host_url,
		                                 'remotepath': ftp_backup_patch_remote_path}
		TeraUtility.ftp_upload(self._output_path, ftp_backup_patch_upload_param)
		pass
	
	# 生成基础包
	def __generate_base(self):
		# 生成基础文件 version.text
		print('__generate_base')
		generate_cmd_str = '%s\\HobaPackToolsCommand.exe %s %s' % (self._packtools_path,
		                                                           self._base_version,
		                                                           self._output_path)
		
		TeraUtility.execute(generate_cmd_str)
		
		#小包需要生成 第一个整资源更新包
		if self._is_smallpack == '1':
			self.__generate_update(True)
			pass
		pass
	
	# 正常更新流程
	def __generate_common_update(self):
		print('__generate_common_update')
		# 更新包
		client_revision = _G.param.input_param.version_param.client_revision
		last_client_revision = _G.param.input_param.version_param.client_last_revision
		
		# 当前版本
		self.__checkout_m1client_to_path(self._current_folder,
		                                 self._current_version,
		                                 None if client_revision == '0' else client_revision)
		
		# 上一个版本
		self.__checkout_m1client_to_path(self._last_folder,
		                                 self._last_version,
		                                 None if last_client_revision == '0' else last_client_revision)
		
		generate_cmd_str = '%s\\HobaPackToolsCommand.exe %s %s %s %s %s %s %s %s' % (self._packtools_path,
		                                                                             self._platform_type,
		                                                                             self._base_version,
		                                                                             self._last_version,
		                                                                             self._current_version,
		                                                                             self._last_folder,
		                                                                             self._current_folder,
		                                                                             self._output_path,
		                                                                             self._is_smallpack)
		TeraUtility.execute(generate_cmd_str)
		pass
	
	# 小包体第一个整资源更新包
	def __generate_first_whole_update(self):
		print('__generate_first_whole_update')
		# 更新包
		client_revision = _G.param.input_param.version_param.client_revision
		
		# 当前版本 取完整版
		next_version = '%s1' % self._current_version[0:-1]
		self.__checkout_m1client_to_path(self._current_folder,
		                                 self._current_version,
		                                 None if client_revision == '0' else client_revision)
		# 上一个版本
		# 因为小包 需要处理掉 svn内的文件 进行比对更新
		if os.path.exists(self._last_folder):
			self._file_helper.delete_file(self._last_folder)
			pass
		if not os.path.exists(self._last_folder):
			os.makedirs(self._last_folder)
			pass
		
		generate_cmd_str = '%s\\HobaPackToolsCommand.exe %s %s %s %s %s %s %s %s' % (self._packtools_path,
		                                                                             self._platform_type,
		                                                                             self._base_version,
		                                                                             self._last_version,
		                                                                             next_version,
		                                                                             self._last_folder,
		                                                                             self._current_folder,
		                                                                             self._output_path,
		                                                                             self._is_smallpack)
		TeraUtility.execute(generate_cmd_str)
		pass
	
	# 生成更新包
	def __generate_update(self, is_small_pack = False):
		# 更新包
		if is_small_pack is True:
			self.__generate_first_whole_update()
		else:
			self.__generate_common_update()
			pass
		pass
	
	
	def __del__(self):
		del self._file_helper
		pass
	
	# Class AutobuildPatch End
	pass
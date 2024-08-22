#-*- encoding=utf8 -*-
from enum import Enum
import pandas as pd
from tera_config import *
# 需要配置盘符 及其路径一致,可直接使用环境备份包 安装


# Unity信息
class UnityParam:
	def __init__(self):
		self._unity_windows_path = '%s\\Unity_Windows\\Editor\\Unity.exe' % Content_Unity_Group_Path
		self._unity_ios_path = '%s\\Unity_iOS\\Editor\\Unity.exe' % Content_Unity_Group_Path
		self._unity_android_path = '%s\\Unity_Android\\Editor\\Unity.exe' % Content_Unity_Group_Path
		self._real_path = None
		pass

	@property
	def real_path(self):
		return self._real_path
	'''
	@property
	def windows_path(self):
		return self._unity_windows_path

	@property
	def ios_path(self):
		return self._unity_ios_path

	@property
	def android_path(self):
		return self._unity_android_path
	'''
	# 修复平台UnityEditor路径
	def fix_unity_path_by_platform(self, platform_type):
		if 'iOS' == platform_type:
			self._real_path = self._unity_ios_path
		elif 'Android' == platform_type:
			self._real_path = self._unity_android_path
		else:
			self._real_path = self._unity_windows_path
			pass
		pass

	# Class UnityParam End
	pass


# 更新工作路径 & 上传信息
class PatchParam:
	def __init__(self):
		self._workspace_path = '%s\\Update_Workspace' % Content_AutoBuild_Tera_Workspace_Path
		self._username = Content_Patch_Username
		self._password = Content_Patch_Password
		self._host_url = Content_Patch_Host_Url
		self._remote_path = Content_Patch_Remote_Path
		pass

	@property
	def workspace_path(self):
		return self._workspace_path

	@property
	def username(self):
		return self._username

	@property
	def password(self):
		return self._password

	@property
	def host_url(self):
		return self._host_url

	@property
	def remote_path(self):
		return self._remote_path

	# Class PatchParam End
	pass


# svn信息
class VersionParam:
	def __init__(self):
		self._base_version = None           # 4.项目基础版本号('1.0.0')
		self._last_version = None           # 5.上个 [程序版本号]
		self._current_version = None        # 6.当前 [程序版本号]
		self._client_revision = None        # 7.客户端   当前 [svn版本号]
		self._art_revision = None           # 8.美术资源 当前 [svn版本号]
		self._client_last_revision = None   # 9.客户端   上个 [svn版本号]
		self._is_smallpack = '0'            # 10.是否为小包(空app,不包含数据 & 资源)
		self._is_build_art = True           # 11.是否需要编译美术资源(AssetBundles)
		self._complatform = None            # 12.渠道名称('cn-dev' / ..)
		pass

	# 项目基础版本号('1.0.0')
	def __get_base_version(self):
		return self._base_version

	def __set_base_version(self, base_version):
		assert (isinstance(base_version, str) and len(base_version) > 0)
		self._base_version = base_version
		pass

	# 上个 [程序版本号]
	def __get_last_version(self):
		return self._last_version

	def __set_last_version(self, last_version):
		assert (isinstance(last_version, str) and len(last_version) > 0)
		self._last_version = last_version
		pass

	# 当前 [程序版本号]
	def __get_current_version(self):
		return self._current_version

	def __set_current_version(self, current_version):
		assert (isinstance(current_version, str) and len(current_version) > 0)
		self._current_version = current_version
		pass

	# 客户端   当前 [svn版本号]
	def __get_client_revision(self):
		return self._client_revision

	def __set_client_revision(self, client_revision):
		assert (isinstance(client_revision, str) and len(client_revision) > 0)
		self._client_revision = client_revision
		pass

	# 客户端   上个 [svn版本号]
	def __get_client_last_revision(self):
		return self._client_last_revision

	def __set_client_last_revision(self, client_last_revision):
		assert (isinstance(client_last_revision, str) and len(client_last_revision) > 0)
		self._client_last_revision = client_last_revision
		pass

	# 美术资源 当前 [svn版本号]
	def __get_art_revision(self):
		return self._art_revision

	def __set_art_revision(self, art_revision):
		assert (isinstance(art_revision, str) and len(art_revision) > 0)
		self._art_revision = art_revision
		pass

	# 是否为小包(空app,不包含数据 & 资源)
	def __get_is_smallpack(self):
		return self._is_smallpack

	def __set_is_smallpack(self, is_smallpack):
		assert (isinstance(self._is_smallpack, str) and len(self._is_smallpack) > 0)
		self._is_smallpack = is_smallpack
		pass

	# 是否需要编译美术资源(AssetBundles)
	def __get_is_build_art(self):
		return self._is_build_art

	def __set_is_build_art(self, is_build_art):
		assert (isinstance(is_build_art, str) and len(is_build_art) > 0)
		self._is_build_art = is_build_art
		pass

	# 渠道名称('cn-dev' / ..)
	def __get_complatform(self):
		return self._complatform

	def __set_complatform(self, complatform):
		assert (isinstance(complatform, str) and len(complatform) > 0)
		self._complatform = complatform
		pass

	base_version = property(__get_base_version, __set_base_version)
	last_version = property(__get_last_version, __set_last_version)
	current_version = property(__get_current_version, __set_current_version)
	client_revision = property(__get_client_revision, __set_client_revision)
	client_last_revision = property(__get_client_last_revision, __set_client_last_revision)
	art_revision = property(__get_art_revision, __set_art_revision)
	is_smallpack = property(__get_is_smallpack, __set_is_smallpack)
	is_build_art = property(__get_is_build_art, __set_is_build_art)
	complatform = property(__get_complatform, __set_complatform)

	# Class VersionParam End
	pass


# 输入类型枚举
class EnumInputParam(Enum):
	EProjet_Name            = 1
	EPlatform_Type          = 2
	EBranch_Path            = 3
	EBase_Version           = 4
	ELast_Version           = 5
	ECurrent_Version        = 6
	EClient_Revision        = 7
	EArt_Revision           = 8
	EClient_Last_Revision   = 9
	EIs_Smallpack           = 10
	EIs_Build_Art           = 11
	EComplatform            = 12
	EBuild_Id               = 13
	EArt_Backup_Versoin     = 14

	# TODO 添加参数请注意
	# MacOS ip 规则必须在最后以为参数
	EMacOS_Ip               = 15
	pass


# 输入的参数
class InputParam:
	"""
	Param: EnumInputParam
	# 1.项目名称
	# 2.平台名称(Windows/Android/iOS)
	# 3.项目分支路径('trunk' / 'branches/kakao-1.0.0')
	# 4.项目基础版本号('1.0.0')
	# 5.上个 [程序版本号]
	# 6.当前 [程序版本号]
	# 7.客户端   当前 [svn版本号]
	# 8.美术资源 当前 [svn版本号]
	# 9.客户端   上个 [svn版本号]
	# 10.是否为小包(空app,不包含数据 & 资源)
	# 11.是否需要编译美术资源(AssetBundles)
	# 12.渠道名称('cn-dev' / ..)
	# 13.AutoBuild开启的序号,用于对应 MySQL中数据对应
	# 14.MacOS 终端 IP
	"""

	def __init__(self):
		self._project_name = None           # 1.项目名称
		self._platform_type = None          # 2.平台名称(Windows/Android/iOS)
		self._branch_path = None            # 3.项目分支路径('trunk' / 'branches/kakao-1.0.0')

		# 版本信息
		self._version_param = VersionParam()# 4-12
		self._build_Id = None               # 13.AutoBuild开启的序号,用于对应 MySQL中数据对应
		self._macos_ip = None               # 14.MacOS 终端 IP
		self._art_backup_version = None     # 15.上一次备份的资源,不需要从打的情况
		pass

	# 项目名称
	def __get_project_name(self):
		return self._project_name

	def __set_project_name(self, project_name):
		assert (isinstance(project_name, str) and len(project_name) > 0)
		self._project_name = project_name
		pass

	# 平台名称(Windows/Android/iOS)
	def __get_platform_type(self):
		return self._platform_type

	def __set_platform_type(self, platform_type):
		assert (isinstance(platform_type, str) and len(platform_type) > 0)
		self._platform_type = platform_type
		pass

	# 项目分支路径('trunk' / 'branches/kakao-1.0.0')
	def __get_branch_path(self):
		return self._branch_path

	def __set_branch_path(self, branch_path):
		assert (isinstance(branch_path, str) and len(branch_path) > 0)
		self._branch_path = branch_path
		pass

	# AutoBuild开启的序号,用于对应 MySQL中数据对应
	def __get_build_Id(self):
		return self._build_Id

	def __set_build_Id(self, build_Id):
		assert (isinstance(build_Id, str) and len(build_Id) > 0)
		self._build_Id = build_Id
		pass
	
	# 14.MacOS 终端 IP
	def __get_macos_ip(self):
		return self._macos_ip
	
	def __set_macos_ip(self, macos_ip):
		assert (isinstance(macos_ip, str) and len(macos_ip) > 0)
		self._macos_ip = macos_ip
		pass

	# # 15.上一次备份的资源,不需要从打的情况
	def __get_art_backup_version(self):
		return self._art_backup_version

	def __set_art_backup_version(self, version):
		assert (isinstance(version, str) and len(version) > 0)
		self._art_backup_version = version
		pass


	# 版本信息
	@property
	def version_param(self):
		return self._version_param

	project_name = property(__get_project_name, __set_project_name)
	platform_type = property(__get_platform_type, __set_platform_type)
	branch_path = property(__get_branch_path, __set_branch_path)
	build_Id = property(__get_build_Id, __set_build_Id)
	macos_ip = property(__get_macos_ip, __set_macos_ip)
	art_backup_version = property(__get_art_backup_version, __set_art_backup_version)
	# Class InputParam End
	pass


# 本地配置的参数
class SvnParam:
	def __init__(self):
		# M1Client svn
		self._client_svn_url = Content_Svn_Client_Url
		# M1Res4Build svn
		self.art_svn_url = Content_Svn_Art_Url
		# svn user & pwd
		self._username = Content_Svn_Username
		self._password = Content_Svn_Password
		pass

	@property
	def client_svn_path(self):
		return self._client_svn_url

	@property
	def art_svn_path(self):
		return self.art_svn_url
		pass

	@property
	def username(self):
		return self._username

	@property
	def password(self):
		return self._password

	#Class SvnParam End
	pass


# 本地Mac配置的参数
class MacOSParam:
	def __init__(self):
		# MacOS terminal info pandas
		self._pd_macos = pd.DataFrame(data=list(Content_MacOS_Data.values()),
		                              index=list(Content_MacOS_Data.keys()),
		                              columns=['username','password','port','workspace','library_path','unity_path'])
		
		# svn user & pwd & ip & # port
		self._username = None
		self._password = None
		self._ip = None
		self._port = None
		self._workspace = None
		self._library_path = None
		self._unity_path = None
		pass

	def select_macos_terminal_by_ip(self, ip):
		b_ret = True
		try:
			self._username = self._pd_macos['username'][ip]
			self._password = self._pd_macos['password'][ip]
			self._port = int(self._pd_macos['port'][ip])
			self._workspace = self._pd_macos['workspace'][ip]
			self._library_path = self._pd_macos['library_path'][ip]
			self._unity_path = self._pd_macos['unity_path'][ip]
			self._ip = ip
		except:
			b_ret = False
		finally:
			return b_ret
		pass
	
	@property
	def ip(self):
		return self._ip
	
	@property
	def port(self):
		return self._port
	
	@property
	def username(self):
		return self._username

	@property
	def password(self):
		return self._password
	
	@property
	def workspace(self):
		return self._workspace
	
	@property
	def library_path(self):
		return self._library_path
	
	@property
	def unity_path(self):
		return self._unity_path
	
	#Class MacOSParam End
	pass


# ftp assetbundle
class FfpBackupAssetbundleParam:
	def __init__(self):
		self._username = Content_Ftp_Backup_Assetbundle_Username
		self._password = Content_Ftp_Backup_Assetbundle_Password
		self._host_url = Content_Ftp_Backup_Assetbundle_Host_Url
		self._remote_path = Content_Ftp_Backup_Assetbundle_Remote_Path
		pass

	@property
	def username(self):
		return self._username

	@property
	def password(self):
		return self._password

	@property
	def host_url(self):
		return self._host_url

	@property
	def remote_path(self):
		return self._remote_path

	# Class FfpBackupAssetbundleParam End
	pass

# ftp package
class FfpBackupPackageParam:
	def __init__(self):
		self._username = Content_Ftp_Backup_Package_Username
		self._password = Content_Ftp_Backup_Package_Password
		self._host_url = Content_Ftp_Backup_Package_Host_Url
		self._remote_path = Content_Ftp_Backup_Package_Remote_Path
		pass

	@property
	def username(self):
		return self._username

	@property
	def password(self):
		return self._password

	@property
	def host_url(self):
		return self._host_url

	@property
	def remote_path(self):
		return self._remote_path
	
	@property
	def fullpath(self):
		return '%s/%s' % (self._host_url, self._remote_path)

	@property
	def dsym_fullpath(self):
		return '%s/%s/%s' % (self._host_url, self._remote_path, Content_Ftp_Backup_Dsyms_Remote_Path)
	# Class FfpBackupPackageParam End
	pass


# ftp patch
class FfpBackupPatchParam:
	def __init__(self):
		self._username = Content_Ftp_Backup_Patch_Username
		self._password = Content_Ftp_Backup_Patch_Password
		self._host_url = Content_Ftp_Backup_Patch_Host_Url
		self._remote_path = Content_Ftp_Backup_Patch_Remote_Path
		pass

	@property
	def username(self):
		return self._username

	@property
	def password(self):
		return self._password

	@property
	def host_url(self):
		return self._host_url

	@property
	def remote_path(self):
		return self._remote_path
# Class FfpBackupPackageParam End


# Autobuild _G.param 全局参数
class TeraParam:
	def __init__(self):
		# log handler
		self._file_log_handler = None
		# 项目最后输出的名称
		self._project_all_name = ''
		# 输入的参数
		self._input_param = InputParam()
		# Unity参数
		self._unity_param = UnityParam()
		# svn参数
		self._svn_param = SvnParam()
		# patch参数
		self._patch_param = PatchParam()
		# assetbundle backup参数
		self._ftp_backup_ab_param = FfpBackupAssetbundleParam()
		# package backup参数
		self._ftp_backup_package_param = FfpBackupPackageParam()
		# patch backup参数
		self._ftp_backup_patch_param = FfpBackupPatchParam()

		# macos ssh终端信息
		self._macos_param = MacOSParam()
		
		# python workspace path
		self._python_workspace_path = Content_AutoBuild_Python_Workspace_Path
		# Tera workspace path
		self._tera_workspace_path = Content_AutoBuild_Tera_Workspace_Path
		
		# m1client_path
		self._m1client_path = 'M1Client'
		# m1res4build_path
		self._m1res4build_path = 'M1Res4Build'
		
		# php完成信息 Post Url
		self._post_finish_url = Content_Post_Finish_Url
		pass
	pass


	@property
	def input_param(self):
		return self._input_param

	@property
	def unity_param(self):
		return self._unity_param

	@property
	def svn_param(self):
		return self._svn_param

	@property
	def patch_param(self):
		return self._patch_param

	@property
	def ftp_backup_ab_param(self):
		return self._ftp_backup_ab_param

	@property
	def ftp_backup_package_param(self):
		return self._ftp_backup_package_param

	@property
	def ftp_backup_patch_param(self):
		return self._ftp_backup_patch_param

	@property
	def macos_param(self):
		return self._macos_param
	
	@property
	def python_workspace_path(self):
		return self._python_workspace_path

	@property
	def tera_workspace_path(self):
		return self._tera_workspace_path


	def get_project_all_name(self):
		return self._project_all_name

	def set_project_all_name(self, project_all_name):
		assert (isinstance(project_all_name, str) and len(project_all_name) > 0)
		self._project_all_name = project_all_name
		
	def get_file_log_handler(self):
		return self._file_log_handler
	
	def set_file_log_handler(self, file_handler):
		self._file_log_handler = file_handler
		
	project_all_name = property(get_project_all_name, set_project_all_name)
	file_log_handler = property(get_file_log_handler,set_file_log_handler)
	
	@property
	def m1client_path(self):
		return self._m1client_path
	
	@property
	def m1res4build_path(self):
		return self._m1res4build_path
		
	@property
	def post_finish_url(self):
		return self._post_finish_url
		
	# 修复平台 M1Client & M1Res4Build 路径
	def fix_working_path(self):
		platfrom_type = self._input_param.platform_type
		
		self._unity_param.fix_unity_path_by_platform(platfrom_type)
		
		self._m1client_path = '%s\\%s_%s' % (self._tera_workspace_path,
		                                     self._m1client_path,
		                                     platfrom_type)
		
		self._m1res4build_path = '%s\\%s_%s' % (self._tera_workspace_path,
		                                        self._m1res4build_path,
		                                        platfrom_type)
		pass
	
	# 修复平台 最后生成包文件 添加对应后缀
	def fix_project_all_name(self):
		platfrom_type = self._input_param.platform_type
		if "Windows" == platfrom_type:
			self.project_all_name = '%s.zip' % self.project_all_name
		elif "iOS" == platfrom_type:
			self.project_all_name = '%s.ipa' % self.project_all_name
		elif "Android" == platfrom_type:
			self.project_all_name = '%s.apk' % self.project_all_name
			pass
		pass
	
	# 查找对应IP的 MacOS SSH配置信息
	def fix_macos_info(self):
		b_ret = True
		if self.input_param.platform_type == 'iOS':
			b_ret = self._macos_param.select_macos_terminal_by_ip(self.input_param.macos_ip)
			pass
		return b_ret
	
	# 获取 当前版本 art svn用的结构
	def get_cur_art_svn_param(self):
		svn_path = '%s/%s' % (self.svn_param.art_svn_path, self.input_param.branch_path)
		local_dest_path = '%s\\%s' % (self._m1res4build_path, self.input_param.branch_path)
		cur_revision = self.input_param.version_param.art_revision
		usr = self.svn_param.username
		pwd = self.svn_param.password
		art_svn_param = {'username': usr, 'password': pwd, 'svnpath': svn_path, 'parentpath': local_dest_path}
		return art_svn_param, cur_revision
	
	# 获取 当前版本 client svn用的结构
	def get_cur_client_svn_param(self):
		svn_path = '%s/%s' % (self.svn_param.client_svn_path, self.input_param.branch_path)
		local_dest_path = '%s\\%s' % (self._m1client_path, self.input_param.branch_path)
		cur_revision = self.input_param.version_param.client_revision
		usr = self.svn_param.username
		pwd = self.svn_param.password
		art_svn_param = {'username': usr, 'password': pwd, 'svnpath': svn_path, 'parentpath': local_dest_path}
		return art_svn_param, cur_revision
	
	# 获取 Assetbundle Ftp URL 备份路径
	def get_ab_download_path(self):
		ab_down_path = '%s/%s/%s/%s' % (self.ftp_backup_ab_param.remote_path,
		                                self.input_param.branch_path,
		                                self.input_param.platform_type,
		                                self.input_param.version_param.current_version)
		
		return ab_down_path
		
	# # 获取 Assetbundle Ftp URL 备份路径
	# def get_build_ios_ssh_cmd_str(self):
	# 	cmd_str = '%s/tera_autobuild.sh %s %s %s %s %s %s %s %s %s' % (self.macos_param.workspace,
	# 	                                                               self.input_param.project_name,
	# 	                                                               self.input_param.branch_path,
	# 	                                                               self.input_param.version_param.base_version,
	# 	                                                               self.input_param.version_param.current_version,
	# 	                                                               self.get_ab_download_path(),
	# 	                                                               self.input_param.version_param.client_revision,
	# 	                                                               self.project_all_name,
	# 	                                                               self.input_param.version_param.complatform,
	# 	                                                               self.input_param.version_param.is_smallpack)
	#
	# 	return cmd_str

	# 获取 Assetbundle Ftp URL 备份路径
	def get_build_ios_ssh_cmd_str(self):
		cmd_str = '%s/tera_autobuild.sh %s %s %s %s %s %s %s %s %s %s %s' % (self.macos_param.workspace,
		                                                                     self.input_param.project_name,
		                                                                     self.input_param.branch_path,
		                                                                     self.input_param.version_param.base_version,
		                                                                     self.input_param.version_param.current_version,
		                                                                     self.get_ab_download_path(),
		                                                                     self.input_param.version_param.client_revision,
		                                                                     self.project_all_name,
		                                                                     self.input_param.version_param.complatform,
		                                                                     self.input_param.version_param.is_smallpack,
		                                                                     self.macos_param.workspace,
		                                                                     self.macos_param.unity_path)
		return cmd_str


	# 获取平台宏定义
	def get_macro_definition(self):
		macro_definition = 'IN_GAME'
		definition_list=[]
		definition_list.append(macro_definition)
		if self.input_param.version_param.complatform.find('kakao-deploy') != -1:
			definition_list.append('USING_FABRIC')
			definition_list.append('PLATFORM_KAKAO')
		elif self.input_param.version_param.complatform.find("kakao-inhouse-deploy") != -1:
			definition_list.append('USING_FABRIC')
			definition_list.append('PLATFORM_KAKAO')
		else:
			pass

		str = ';'
		if len(definition_list) > 1:
			macro_definition = str.join(definition_list)
		else:
			macro_definition = macro_definition + str;
			pass

		return macro_definition
	
	def __del__(self):
		del self._input_param
		del self._unity_param
		del self._svn_param
		del self._patch_param
		del self._ftp_backup_ab_param
		del self._ftp_backup_package_param
		self.file_log_handler.close()
		
		pass

	# Class TeraParam End
	pass
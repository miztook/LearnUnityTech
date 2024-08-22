#-*- encoding=utf8 -*-

from tera_param import TeraParam, EnumInputParam
import tera_globals as _G
from tera_utility import *
from filehelper import FileHelper
from tera_autobuild_art import AutobuildArt
from tera_autobuild_client import AutobuildClient
from tera_autobuild_patch import AutobuildPatch
import sys
import datetime

_G.param = None

###################################################################################
#           Tera Auto Build Entrance (M1Res4Build & M1Client & Patch)
#
# 1. Set setting path first please!
# 2. php call
# 3. param:[]
#
#
# Date:2017.11.30
###################################################################################

def initialize():
    if len(sys.argv) == (EnumInputParam.__len__() + 1):
        _G.param.input_param.project_name = sys.argv[EnumInputParam.EProjet_Name.value]
        _G.param.input_param.platform_type = sys.argv[EnumInputParam.EPlatform_Type.value]
        _G.param.input_param.branch_path = sys.argv[EnumInputParam.EBranch_Path.value]
        _G.param.input_param.version_param.base_version = sys.argv[EnumInputParam.EBase_Version.value]
        _G.param.input_param.version_param.last_version = sys.argv[EnumInputParam.ELast_Version.value]
        _G.param.input_param.version_param.current_version = sys.argv[EnumInputParam.ECurrent_Version.value]
        _G.param.input_param.version_param.client_revision = sys.argv[EnumInputParam.EClient_Revision.value]
        _G.param.input_param.version_param.art_revision = sys.argv[EnumInputParam.EArt_Revision.value]
        _G.param.input_param.version_param.client_last_revision = sys.argv[EnumInputParam.EClient_Last_Revision.value]
        
        # Windows 为整包体
        _G.param.input_param.version_param.is_smallpack = '1' if ((sys.argv[EnumInputParam.EIs_Smallpack.value]=='1') and
                                                           _G.param.input_param.platform_type != 'Windows') else '0'
        
        _G.param.input_param.version_param.is_build_art = sys.argv[EnumInputParam.EIs_Build_Art.value]
        _G.param.input_param.version_param.complatform = sys.argv[EnumInputParam.EComplatform.value]
        _G.param.input_param.build_Id = sys.argv[EnumInputParam.EBuild_Id.value]
        
        _G.param.input_param.macos_ip = sys.argv[EnumInputParam.EMacOS_Ip.value]
        _G.param.input_param.art_backup_version = sys.argv[EnumInputParam.EArt_Backup_Versoin.value]

        # 通过平台修复路径
        _G.param.fix_working_path()
        # 选择MacOS终端信息
        if _G.param.fix_macos_info() is False:
            TeraUtility.failed_exit()
            pass
    else:
        print('Error param count.', len(sys.argv))
        TeraUtility.failed_exit()
        pass
    
    print('Input Param============================================Begin')
    print('Disk Free Space : %0.2f GB' % TeraUtility.get_free_space('X:\\'))
    print('IP %s' % TeraUtility.get_ip())
    
    print('project_name = %s' % _G.param.input_param.project_name)
    print('platform_type = %s' % _G.param.input_param.platform_type)
    print('branch_path = %s' % _G.param.input_param.branch_path)
    print('base_version = %s' % _G.param.input_param.version_param.base_version)
    print('last_version = %s' % _G.param.input_param.version_param.last_version)
    print('current_version = %s' % _G.param.input_param.version_param.current_version)
    print('client_revision = %s' % _G.param.input_param.version_param.client_revision)
    print('art_revision = %s' % _G.param.input_param.version_param.art_revision)
    print('client_last_revision = %s' % _G.param.input_param.version_param.client_last_revision)
    print('is_smallpack = %s' % _G.param.input_param.version_param.is_smallpack)
    print('is_build_art = %s' % _G.param.input_param.version_param.is_build_art)
    print('complatform = %s' % _G.param.input_param.version_param.complatform)
    print('build_Id = %s' % _G.param.input_param.build_Id)
    print('macos_ip = %s' % _G.param.input_param.macos_ip)
    print('MacOS Info  IP = %s' % _G.param.macos_param.ip)
    #print('MacOS Info  usr = %s' % _G.param.macos_param.username)
    #print('MacOS Info  pwd = %s' % _G.param.macos_param.password)
    print('MacOS Info  port = %s' % _G.param.macos_param.port)
    print('MacOS Info  workspace = %s' % _G.param.macos_param.workspace)
    print('MacOS Info  unity_path = %s' % _G.param.macos_param.unity_path)
    print('Art backup version = %s' % _G.param.input_param.art_backup_version)

    print('Input Param============================================End\n')
    _G.param.file_log_handler.flush()
    
    print('[Start Time : %s]' % datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S'))
    # set current project name
    _G.param.project_all_name = TeraUtility.padding([_G.param.input_param.project_name,
                                                     _G.param.input_param.version_param.complatform,
                                                     datetime.date.today(),
                                                     _G.param.input_param.platform_type,
                                                     _G.param.input_param.version_param.base_version])
    _G.param.fix_project_all_name()
    print('[Project Name : %s]' % _G.param.project_all_name)
    
    # create workspace first time
    tera_workspace_path = _G.param.tera_workspace_path
    if not os.path.exists(tera_workspace_path):
        os.makedirs(tera_workspace_path)
        pass

    os.chdir(tera_workspace_path)
    pass

def start():
    # Build Assetbundle & Client Logic
    b_is_build_art = (_G.param.input_param.version_param.is_build_art == '1')
    platform_type = _G.param.input_param.platform_type
    project_all_name = _G.param.project_all_name
    m1client_path = _G.param.m1client_path
    branch_path = _G.param.input_param.branch_path
    base_version = _G.param.input_param.version_param.base_version
    current_version = _G.param.input_param.version_param.current_version
    last_version = _G.param.input_param.version_param.last_version
    complatform = _G.param.input_param.version_param.complatform

    
    ftp_ab_usr = _G.param.ftp_backup_ab_param.username
    ftp_ab_pwd = _G.param.ftp_backup_ab_param.password
    ftp_ab_host_url = _G.param.ftp_backup_ab_param.host_url
    ftp_ab_remote_path = _G.param.ftp_backup_ab_param.remote_path
    art_backup_version = _G.param.input_param.art_backup_version
    b_is_build_art = (b_is_build_art and art_backup_version == '0')

    print('[Need Build Art = < %s >)] ' % b_is_build_art)

    if b_is_build_art:
        # TODO Build Assetbundle
        autobuild_art = AutobuildArt()
        AutobuildArt.start()
        
        # TODO Backup Assetbundle
        if base_version == current_version:
            # Base version
            print('Backup Base version')
            ftp_ab_full_path = '%s/%s/%s/%s/Base' % (ftp_ab_remote_path, branch_path, platform_type, base_version)
            ftp_ab_upload_param = {'username': ftp_ab_usr,
                                   'password': ftp_ab_pwd,
                                   'hostpath': ftp_ab_host_url,
                                   'remotepath': ftp_ab_full_path}
            TeraUtility.ftp_upload(autobuild_art.export_path, ftp_ab_upload_param, '.manifest')
        else:
            # Update version
            ftp_ab_full_path = '%s/%s/%s/%s/Update_%s' % (ftp_ab_remote_path,
                                                          branch_path,
                                                          platform_type,
                                                          base_version,
                                                          current_version)
            ftp_ab_upload_param = {'username': ftp_ab_usr,
                                   'password': ftp_ab_pwd,
                                   'hostpath': ftp_ab_host_url,
                                   'remotepath': ftp_ab_full_path}
            TeraUtility.ftp_upload('%s/Update' % autobuild_art.export_path, ftp_ab_upload_param, '.manifest')
            pass
        del autobuild_art
    else:
        # TODO 1.Download backup Assetbundles & 2.Backup to current Version
        # Update version
        print('Backup Update version')
        ftp_ab_full_path = '%s/%s/%s/%s' % (ftp_ab_remote_path,branch_path,platform_type,base_version)
        
        # 创建上传，下载的工作路径
        ab_upload_path = '%s/ab_upload_path' % _G.param.tera_workspace_path
        _G.log('ab_upload_path = %s' % ab_upload_path)
        if os.path.exists(ab_upload_path):
            FileHelper.delete_folder(ab_upload_path)
            pass
        if not os.path.exists(ab_upload_path):
            os.makedirs(ab_upload_path)
            pass

        ab_ftp_upload_param = None
        # 基础包，不需要打资源的情况
        if current_version == base_version and len(art_backup_version) > 1:
            ftp_ab_full_path = '%s/%s/%s/%s/Base' % (ftp_ab_remote_path,branch_path,platform_type,art_backup_version)

            ab_ftp_download_param = {'username': ftp_ab_usr,
                                     'password': ftp_ab_pwd,
                                     'hostpath': ftp_ab_host_url,
                                     'remotepath': ftp_ab_full_path}

            # 存在传来的备份版本信息，下载。否则 重新打包
            if TeraUtility.ftp_file_exist(ab_ftp_download_param) is True:
                TeraUtility.ftp_download(ab_upload_path, ab_ftp_download_param)
                ftp_ab_full_path = '%s/%s/%s/%s/Base' % (ftp_ab_remote_path, branch_path, platform_type, base_version)
            else:
                autobuild_art = AutobuildArt()
                AutobuildArt.start()

                ftp_ab_full_path = '%s/%s/%s/%s/Base' % (ftp_ab_remote_path, branch_path, platform_type, base_version)
                ab_upload_path = autobuild_art.export_path
                del autobuild_art
                pass

            ab_ftp_upload_param = {'username': ftp_ab_usr,
                                   'password': ftp_ab_pwd,
                                   'hostpath': ftp_ab_host_url,
                                   'remotepath': ftp_ab_full_path}
        else:
            if last_version == base_version:
                # 上一个版本是基础包，没有Update保存
                #os.makedirs('%s/Update' % ab_upload_path)
                pass
            else:
                # 上一次有备份 'Update_%s' % Last_version
                ab_ftp_download_param = {'username': ftp_ab_usr,
                                         'password': ftp_ab_pwd,
                                         'hostpath': ftp_ab_host_url,
                                         'remotepath': '%s/Update_%s' % (ftp_ab_full_path, last_version)}
                TeraUtility.ftp_download(ab_upload_path, ab_ftp_download_param)
                pass
            ab_ftp_upload_param = {'username': ftp_ab_usr,
                                   'password': ftp_ab_pwd,
                                   'hostpath': ftp_ab_host_url,
                                   'remotepath': '%s/Update_%s' % (ftp_ab_full_path, current_version)}
            pass

        TeraUtility.ftp_upload(ab_upload_path, ab_ftp_upload_param, '.manifest')
        pass
    
    # Just export app for baseVersion
    if base_version == current_version:
        # TODO Build Client
        AutobuildClient.start()
        
        # Windows & Android Using PC, so except iOS
        if 'iOS' != platform_type:
            package_path = '%s\\%s\\Package' % (m1client_path, branch_path)
            local_package_upload_path = '%s\\%s\\ftp_upload' % (m1client_path, branch_path)
            if 'Android' == platform_type:
                local_package_upload_path = package_path
            else:
                # zip app
                TeraUtility.zip_file(project_all_name, package_path, local_package_upload_path)
                pass

            # upload app
            ftp_pkg_usr = _G.param.ftp_backup_package_param.username
            ftp_pkg_pwd = _G.param.ftp_backup_package_param.password
            ftp_pkg_host_url = _G.param.ftp_backup_package_param.host_url
            ftp_pkg_remote_path = _G.param.ftp_backup_package_param.remote_path
            ftp_pkg_full_path = '%s/%s' % (ftp_pkg_remote_path,platform_type)
            
            pkg_ftp_upload_param = {'username': ftp_pkg_usr,
                                    'password': ftp_pkg_pwd,
                                    'hostpath': ftp_pkg_host_url,
                                    'remotepath': ftp_pkg_full_path}
            
            TeraUtility.ftp_upload(local_package_upload_path, pkg_ftp_upload_param, '.manifest')
            pass
        pass
    
    # TODO Patch
    autobuild_patch = AutobuildPatch()
    autobuild_patch.start()
    autobuild_patch.clean()
    
    del autobuild_patch
    pass
   
    

# Main Entrance
if __name__ == '__main__':
    file_handler = open(TeraUtility.get_start_log_path(), 'a+')
    start_time = datetime.datetime.now()
    file_handler.write('===================================\n')
    file_handler.write('%s\n' % start_time.strftime('%Y-%m-%d %H:%M:%S'))
    for argv in sys.argv:
        file_handler.writelines(argv)
        file_handler.writelines('\n')
        file_handler.flush()
        pass
    file_handler.close()
    del file_handler
    
    # Init TeraParam
    _G.param = TeraParam()
    
    #check is running, or start
    log_path = TeraUtility.get_log_path()
    if os.path.exists(log_path):
        os.remove(log_path)
        pass
    
    # stdout 写文件
    _G.param.file_log_handler = open(TeraUtility.get_log_path(), 'a+')
    sys.stdout = _G.param.file_log_handler

    # 运行中不可同时操作, 直接跳出
    TeraUtility.try_start_build()
    
    # 初始化工作区, 项目名称
    initialize()
    
    # TODO 开始打包逻辑
    start()

    end_time = datetime.datetime.now()
    total_seconds = (end_time - start_time).total_seconds()
    _G.log('total time:< %d seconds > = < %0.3f hours >' % (total_seconds / 60, total_seconds / 3600))
    
    # TODO post http succeed
    TeraUtility.success_exit()
    del _G.param
    pass
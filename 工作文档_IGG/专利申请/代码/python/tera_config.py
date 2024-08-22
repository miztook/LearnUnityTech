# -*- encoding=utf8 -*-

################################################################
# ReadMe：
# 1.Python环境    Anaconda Python3.6
# 2.Unity环境     UnityEditorGroup 5.3.6p3
# 3.使用者机器参数 需要手动设置; 修改以下参数 即可完成打包工程配置
################################################################

## AutoBuild 工程路径
Content_AutoBuild_Python_Workspace_Path = 'X:\\Python_Workspace'
Content_AutoBuild_Tera_Workspace_Path = 'X:\\_'    #'X:\\Tera_Workspace'

## Unity 相关
Content_Unity_Group_Path = 'X:\\UnityEditorGroup'

## Android SDK 相关
Content_Android_Platforms_Path = 'X:\\AndroidEnv\\android-sdk\\platforms'
Content_Android_All_Platforms_Path = 'X:\\AndroidEnv\\all_android_api_platforms'

## Patch 相关
Content_Patch_Username = 'Patch_Username'
Content_Patch_Password = 'Patch_Password'
Content_Patch_Host_Url = '10.35.49.163'
Content_Patch_Remote_Path = '/Patch_Remote_Path/Tera'

## Svn 相关
Content_Svn_Client_Url = 'svn://10.35.49.171/M1Client'
Content_Svn_Art_Url = 'svn://10.35.49.171/M1Res4Build'
Content_Svn_Username = 'Svn_Username'
Content_Svn_Password = 'Svn_Password'

## php完成信息 Post Url
Content_Post_Finish_Url = 'http://10.35.51.30/buildcmd_finish'

## ftp backup Assetbundle 相关
Content_Ftp_Backup_Assetbundle_Username = 'Assetbundle_Username'
Content_Ftp_Backup_Assetbundle_Password = 'Assetbundle_Password'
Content_Ftp_Backup_Assetbundle_Host_Url = '10.35.51.37'
Content_Ftp_Backup_Assetbundle_Remote_Path = 'M1Res4Build_Export'

## ftp backup Package 相关
Content_Ftp_Backup_Package_Username = 'Package_Username'
Content_Ftp_Backup_Package_Password = 'Package_Password'
Content_Ftp_Backup_Package_Host_Url = '10.35.51.37'
Content_Ftp_Backup_Package_Remote_Path = 'Package_Backup'
Content_Ftp_Backup_Dsyms_Remote_Path = "dsyms"

## ftp backup Patch 相关
Content_Ftp_Backup_Patch_Username = 'Backup_Patch_Username'
Content_Ftp_Backup_Patch_Password = 'Backup_Patch_Password'
Content_Ftp_Backup_Patch_Host_Url = '10.35.51.37'
Content_Ftp_Backup_Patch_Remote_Path = 'Patch_Backup'


## MacOS终端 ssh信息  IP:['用户名','密码','端口号','workspace','library_path', 'unity_path']
Content_MacOS_Data = {'10.35.51.41':['usrname',
                                     'password',
                                     '22',
                                     '/Users/tera/Documents/Tera_Workspace',
                                     '/Users/tera/Library',
                                     '/Applications/Unity'],
                      '10.35.51.40': ['usrname',
                                      'password',
                                      '22',
                                      '/Users/lantu/Documents/Tera_Workspace',
                                      '/Users/lantu/Library',
                                      '/Applications/Unity'],
                      }

Content_Android_Api = {'kakao':[28],
                       'dev':[26],
                      }
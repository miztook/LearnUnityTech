#-*- encoding=utf8 -*-

import os,shutil,subprocess

class FileHelper:
    def __init__(self):
        pass
    
    @staticmethod
    def __execute(cmd):
        print('execute: [{}]'.format(cmd))
        mytask = subprocess.Popen(cmd, shell=True)
        while mytask.poll() is None:
            pass
        pass

        if mytask.returncode == 0:
            print('Command success')
        else:
            print('Command failed')
            pass
        
    @staticmethod
    def copy_tree(src, dst, ignore=None):
        if not os.path.exists(src):
            print('src path do not exists')
            return
        pass

        names = os.listdir(src)
        if not os.path.exists(dst):
            os.makedirs(dst)
        for name in names:
            if ignore is not None and type(ignore) == type('a') and name.find(ignore) > 0:
                continue
                pass

            srcname = os.path.join(src, name)
            dstname = os.path.join(dst, name)
            try:
                if os.path.isdir(srcname):
                    FileHelper.copy_tree(srcname, dstname)
                else:
                    if (not os.path.exists(dstname) or ((os.path.exists(dstname)) and (os.path.getsize(dstname) != os.path.getsize(srcname)))):
                        print('Copy [%s]' % dstname)
                        shutil.copy2(srcname, dst)
                        pass
                    pass
            except:
                raise
            pass
        pass
    
    @staticmethod
    def delete_file(file_name):
        try:
            os.remove(file_name)
            print('File deleted: %s' % file_name)
        except:
            print('Failed to delete file: %s' % file_name)
        pass
    
    @staticmethod
    def delete_files(file_name_list):
        for file_name in file_name_list:
            FileHelper.delete_file(file_name)
        pass
    
    @staticmethod
    def delete_folder(delete_path):
        del_path = str(delete_path).replace('/', '\\')
        if os.path.exists(del_path):
            cmd_str = 'rd /s /q %s' % del_path
            FileHelper.__execute(cmd_str)
            pass
        pass
    
    @staticmethod
    def delete_file_with_suffix(delete_path, suffix):
        delete_path = str(delete_path).replace('/', '\\')
        if os.path.isdir(delete_path):
            cmd_str = 'del /a /f /q %s %s' % (delete_path, suffix)
            FileHelper.__execute(cmd_str)
        pass
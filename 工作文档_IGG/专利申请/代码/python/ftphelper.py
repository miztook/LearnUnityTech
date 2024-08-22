#!/bin/env python
#-*- encoding=utf8 -*-

from ftplib import FTP
import os

class FtpHelper():
    _username=''
    _password=''
    _hostpath=''
    _remotepath=''
    _initialized=False
    _ftp=None
    _file_list = []

    def __init__(self, param):
        try:
            self._username = param['username']
            self._password = param['password']
            self._hostpath = param['hostpath']
            self._remotepath = param['remotepath']

            #print(param['username'])
            #print(param['password'])
            print('hostpath:: ' + param['hostpath'])
            print('remotepath:: ' + param['remotepath'])
            self._ftp = FTP()
        except:
            print('Error FtpHelper::Init Failed!')
            exit(-1)
        else:
            self._initialized = True
        pass

    def __connect(self):
        print('Ftp Connecting')
        if self._initialized is False:
            print('FtpHelper must be initialized.')
            return
        pass

        try:
            self._ftp.connect(self._hostpath, 21)
            self._ftp.login(self._username, self._password)
            print('Ftp Connect!')
        except:
            print('Error login or connect failed!')
        pass

        try:
            self._ftp.cwd(self._remotepath)
        except:
            print('Error change server dir failed')
        pass

    def __is_same_size(self, local_file, remote_file):
        try:
            remotefile_size = self._ftp.size(remote_file)
        except:
            remotefile_size = -1
        pass

        try:
            localfile_size = os.path.getsize(local_file)
        except:
            localfile_size = -1
        pass

        print ('lo:%d  re:%d' % (localfile_size, remotefile_size))
        return True if remotefile_size == localfile_size else False

    def login(self):
        self.__connect()
        pass

    def quit(self):
        self._ftp.close()
        pass

    def get_file_list(self, line):
        file_arr = self.get_filename(line)
        #print('file_arr = %s' % line)
        
        if file_arr[1] not in ['.', '..']:
            self._file_list.append(file_arr)

    def get_filename(self, line):
        file_type = 0 if line[0]=='d' else -1#line.find('<DIR>')
        file_name = line.split(" ")[-1]
        file_arr = [file_type, file_name]
        return file_arr

    def download_file(self, local_file, remote_path):
        print('>>>>>>>>>>>>下载文件 %s ... ...' % local_file)
        file_handler = open(local_file, 'wb')
        self._ftp.retrbinary('RETR %s' % remote_path, file_handler.write)
        file_handler.close()
        pass

    def download_files(self, local_path='./', remote_path='./'):
        print('>>>>>>>>>>>>下载文件夹 %s ... ...' % remote_path)
        try:
            self._ftp.cwd(remote_path)
        except:
            print('目录%s不存在' % remote_path)
            return
        
        if os.path.exists(local_path):
            from filehelper import FileHelper
            FileHelper.delete_folder(local_path)
            pass
        
        if not os.path.isdir(local_path):
            os.makedirs(local_path)
            pass
        
        self._file_list = []
        self._ftp.dir(self.get_file_list)
        remotenames = self._file_list

        for item in remotenames:
            filetype = item[0]
            filename = item[1]
            local = os.path.join(local_path, filename)

            if filetype != -1:
                self.download_files(local, filename)
            else:
                self.download_file(local, filename)
                pass
            pass
        self._ftp.cwd('..')
        pass
    
    def upload_file(self, local_file, remote_file, ingore=None):
        if not os.path.isfile(local_file):
            return
        pass
        print('[========================upload_file=========================]')
        print('local_file = [%s]' % local_file)
        print('remote_file = [%s]' % remote_file)
        print('ingore = %s' % ingore)
        if ingore is not None and (local_file.find(ingore) != -1):
            return
            # if self.__is_same_size(local_file, remote_file):
            #     print('Has same size file already exist: %s' % local_file)
            #     return
            # pass
        pass

        file_handler = open(local_file, 'rb')
        self._ftp.storbinary('STOR %s' % remote_file, file_handler)
        file_handler.close()
        pass
    
    def upload_files(self, local_path='./', remote_path='./', ingore=None):
        if not os.path.isdir(local_path):
            return
        
        self._ftp.cwd(remote_path)
        local_names = os.listdir(local_path)
        for item in local_names:
            src = os.path.join(local_path, item)
            if os.path.isdir(src):
                try:
                    self._ftp.mkd(item)
                except:
                    print('folder has already exist: %s' % item)
                pass

                self.upload_files(src, item, ingore)
            else:
                self.upload_file(src, item, ingore)
            pass
        pass

        self._ftp.cwd('..')
        pass
    
    # 创建检查ftp 是否存在结构，
    def create_dir(self, path):
        try:
            self._ftp.cwd(path)
        except:
            sub_path_list = path.split("/")
            dest_path = '/'
            for sub_path in sub_path_list:
                dest_path = '%s/%s' % (dest_path, sub_path)
                try:
                    self._ftp.cwd(dest_path)
                except:
                    self._ftp.mkd(dest_path)
                pass
            pass
        self._ftp.cwd("/")
        pass

    def cwd_front(self):
        print('%s' % self._ftp.pwd())
        self._ftp.cwd('..')
        pass

    def cwd(self, cmd):
        self._ftp.cwd(cmd)
        pass

    def file_exist(self, path):
        bRet = False
        try:
            self._ftp.cwd(path)
            bRet = True
        except:
            pass
        return bRet

    pass
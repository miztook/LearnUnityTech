#-*- encoding=utf8 -*-

import os
from tera_utility import TeraUtility

class SvnHelper:
    initialized=False
    username=None
    password=None
    svnpath=None
    parentpath=None


    def __init__(self, param):
        try:
            self.username = param['username']
            self.password = param['password']
            self.svnpath = param['svnpath']
            self.parentpath = param['parentpath']

            #print('username = %s' % param['username'])
            #print('password = %s' % param['password'])
            #print('svnpath = %s' % param['svnpath'])
            #print('parentpath = %s' % param['parentpath'])
        except:
            print('Error SvnHelp::Init Failed!')
            exit(-1)
        else:
            self.initialized = True
        pass

    def svn_process(self, cmd):
        if not self.initialized:
            return
        print('Not Coding finish! Can not use this function!')
        pass

    def show_svn_log(self, process):
        if process is None:
            return

        while process.poll() is None:
            line = process.stdout.readline()
            line = line.strip()
            if line:
                print('Subprogram output: [{}]'.format(line))
                pass
            pass

        if process.returncode == 0:
            print('Subprogram success')
        else:
            print('Subprogram failed')
            pass
        pass

    def commit(self, dest_path, msg='python svnhelper commit'):
        if not self.initialized:
            return

        print('svn commit')
        strCmd = 'svn ci %s -m \'%s\' --username %s --password %s' % (dest_path, msg, self.username, self.password)
        TeraUtility.execute(strCmd)
        pass

    def checkout(self, revision=None):
        if not self.initialized:
            return

        strCmd='svn co %s -r %s %s --username %s --password %s' % (self.svnpath, 'HEAD' if (revision is None or type(revision) != type('a')) else revision, self.parentpath, self.username, self.password)
        TeraUtility.execute(strCmd)
        pass

    def update(self):
        if not self.initialized:
            return

        print('svn update')
        strCmd = 'svn up %s --username %s --password %s' % (self.parentpath ,self.username, self.password)
        TeraUtility.execute(strCmd)
        pass

    def cleanup(self):
        if not self.initialized:
            return

        print('svn cleanup')
        if not os.path.exists(self.parentpath):
            print('dest path not exist!')
            return

        strCmd = 'svn cleanup %s --username %s --password %s' % (self.parentpath ,self.username, self.password)
        TeraUtility.execute(strCmd)
        pass

    def revert(self):
        if not self.initialized:
            return

        print('svn revert')
        strCmd = 'svn revert -R %s --username %s --password %s' % (self.parentpath, self.username, self.password)
        TeraUtility.execute(strCmd)
        pass

    def add(self, dest_path):
        if not self.initialized:
            return

        print('svn add')
        strCmd = 'svn add %s --username %s --password %s --force' % (dest_path, self.username, self.password)
        TeraUtility.execute(strCmd)
        pass

    def delete(self, dest_path, del_folder=True):
        if not self.initialized:
            return

        print('svn delete')
        strCmd =''
        if del_folder:
            strCmd = 'svn del %s --username %s --password %s --force' % (dest_path, self.username, self.password)
        else:
            strCmd = 'svn del %s/* --username %s --password %s --force' % (dest_path, self.username, self.password)
        pass
        TeraUtility.execute(strCmd)
        pass
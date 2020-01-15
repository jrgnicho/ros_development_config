#!/usr/bin/env python3
import os
import sys
import subprocess

HOME_VAR = 'HOME'
COLCON_VAR = 'COLCON_PREFIX_PATH'
ROS_DISTRO_VAR = 'ROS_DISTRO'
ROS_DEVEL_CONFIG_PATH = os.path.join(os.path.expandvars('$HOME'), os.path.basename('ros_development_config'))

WS_INSTALL_DIR_NAME = 'install'
WS_ECLIPSE_PROJECTS_DIR_NAME = 'projects'
WS_SRC_DIR_NAME = 'src'
WS_INSTALL_DIR_NAME = 'install'
ROS_DISTRO_PATH_TEMPLATE = '/opt/ros/ROS_DISTRO'

ECLIPSE_TEMPLATE_PATH = os.path.join(ROS_DEVEL_CONFIG_PATH , 'eclipse' ,'project_templates')
ECLIPSE_CPROJECT_FILE = '.cproject'
ECLIPSE_PROJECT_FILE = '.project'
ECLIPSE_LANG_SETTINGS_FILE = os.path.join('.settings','language.settings.xml')

ECLIPSE_PROJECT_NAME_TOKEN = '${ProjName}'
ECLIPSE_PROJECT_PATH_TOKEN = '${ProjPath}'
ECLIPSE_WS_PATH_TOKEN = '${WorkspacePath}'
ECLIPSE_WS_INSTALL_PATH_TOKEN = '${WSInstallPath}'
ECLIPSE_ROS_DISTRO_PATH_TOKEN ='${ROSDistroPath}'

if __name__ == '__main__':
    
    if len(sys.argv) < 2:
        print('Needs the ROS2 package name')
        sys.exit(-1)
        
    colcon_pkg = sys.argv[1]
    
    # get colcon env info
    CURRENT_COLCON_WS = ''
    WS_ECLIPSE_PROJECTS_PATH = ''
    if COLCON_VAR not in os.environ :
        print('COLCON WS was not found')
        sys.exit(-1)

    CURRENT_COLCON_WS = os.environ[COLCON_VAR]
    CURRENT_COLCON_WS = CURRENT_COLCON_WS.replace('/' + WS_INSTALL_DIR_NAME, '')
    WS_ECLIPSE_PROJECTS_PATH = os.path.join(CURRENT_COLCON_WS, WS_ECLIPSE_PROJECTS_DIR_NAME)

    # get ros distro
    if ROS_DISTRO_VAR not in os.environ :
        print('%s env var was not found'%(ROS_DISTRO_VAR))
        sys.exit(-1)
    ROS_DISTRO_PATH = ROS_DISTRO_PATH_TEMPLATE.replace('ROS_DISTRO',os.environ[ROS_DISTRO_VAR])
    
    # checking paths
    if not os.path.exists(CURRENT_COLCON_WS):
        print('COLCON WS path %s does not exists'%(CURRENT_COLCON_WS))
        sys.exit(-1)
        
    print('Found COLCON WS at %s' % (CURRENT_COLCON_WS))    
        
    if not os.path.exists(WS_ECLIPSE_PROJECTS_PATH):
        os.mkdir(WS_ECLIPSE_PROJECTS_PATH)
        print('Created Eclipse projects directory at %s' % (WS_ECLIPSE_PROJECTS_PATH))

    # obtaining project path
    colcon_pkg_path=''
    try:
      cmd1 = 'cd %s'%(CURRENT_COLCON_WS)
      cmd2 = 'colcon info --packages-select %s| grep path'%(colcon_pkg)
      process = subprocess.run(cmd1 +' && ' + cmd2, shell=True, check=True, stdout=subprocess.PIPE, universal_newlines=True)
      colcon_pkg_path = process.stdout.split('\n')[0].split(' ')[1]
    except subprocess.CalledProcessError as e:
      print(e.output)
      sys.exit(-1)

    # check package path existence
    if not os.path.exists(colcon_pkg_path):
        print('package path %s does not exists'%(colcon_pkg_path))
        sys.exit(-1)
        
    # creating eclipse project files
    eclipse_files = [ECLIPSE_CPROJECT_FILE, ECLIPSE_PROJECT_FILE,ECLIPSE_LANG_SETTINGS_FILE]
    subs_tokens = {}
    subs_tokens[ECLIPSE_PROJECT_NAME_TOKEN] = colcon_pkg
    subs_tokens[ECLIPSE_PROJECT_PATH_TOKEN] = colcon_pkg_path
    subs_tokens[ECLIPSE_WS_PATH_TOKEN] = CURRENT_COLCON_WS
    subs_tokens[ECLIPSE_WS_INSTALL_PATH_TOKEN] = os.path.join(CURRENT_COLCON_WS, WS_INSTALL_DIR_NAME)
    subs_tokens[ECLIPSE_ROS_DISTRO_PATH_TOKEN] = ROS_DISTRO_PATH
    
        # Read in the file
    for fpath in eclipse_files:
        with open(os.path.join(ECLIPSE_TEMPLATE_PATH,fpath), 'r') as f :
            filedata = f.read()
        
        # Replace the target string
        for token, str_rep in subs_tokens.items():
            filedata = filedata.replace(token, str_rep)
        
        # Write the file out again
        out_file_path = os.path.join(WS_ECLIPSE_PROJECTS_PATH,colcon_pkg,fpath)
        
        # check parent path
        parent_path = os.path.dirname(out_file_path)
        if parent_path != WS_ECLIPSE_PROJECTS_PATH:
            try:
                os.makedirs(parent_path,  exist_ok=True)
            except OSError:
                print ("Creation of the directory %s failed" % parent_path)
                sys.exit(-1)                
        
        # writing package specific file to project directory
        with open(out_file_path, 'w') as out_f:
            out_f.write(filedata)
        print ("Successfully created the eclipse project file %s" % out_file_path)



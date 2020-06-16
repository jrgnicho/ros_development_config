#!/usr/bin/env python3
import os
import sys
import subprocess
import shutil
import xml.etree.ElementTree as ET

HOME_VAR = 'HOME'
COLCON_VAR = 'COLCON_PREFIX_PATH'
ROS_DISTRO_VAR = 'ROS_DISTRO'
ROS_DEVEL_CONFIG_PATH = os.path.join(os.path.expandvars('$HOME'), os.path.basename('ros_development_config'))

WS_INSTALL_DIR_NAME = 'install'
WS_BUILD_DIR_NAME = 'build'
WS_ECLIPSE_PROJECTS_DIR_NAME = 'projects'
WS_SRC_DIR_NAME = 'src'
WS_INSTALL_DIR_NAME = 'install'
ROS_DISTRO_PATH_TEMPLATE = '/opt/ros/ROS_DISTRO'

ECLIPSE_TEMPLATE_PATH = os.path.join(ROS_DEVEL_CONFIG_PATH , 'eclipse' ,'project_templates')
ECLIPSE_CPROJECT_FILE = '.cproject'
ECLIPSE_TEMPLATE_CPROJECT_FILE = '.cproject_template'
ECLIPSE_PROJECT_FILE = '.project'
ECLIPSE_LANG_SETTINGS_FILE = os.path.join('.settings','language.settings.xml')

ECLIPSE_PROJECT_NAME_TOKEN = '${ProjName}'
ECLIPSE_PROJECT_PATH_TOKEN = '${ProjPath}'
ECLIPSE_WS_PATH_TOKEN = '${WorkspacePath}'
ECLIPSE_WS_INSTALL_PATH_TOKEN = '${WSInstallPath}'
ECLIPSE_ROS_DISTRO_PATH_TOKEN ='${ROSDistroPath}'

CPROJECT_XML_DECLARATIONS = '''<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<?fileVersion 4.0.0?>
'''

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

    CURRENT_COLCON_WS = os.environ[COLCON_VAR].split(':')[0]
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

    if not os.path.isabs(colcon_pkg_path):
        colcon_pkg_path = os.path.join(CURRENT_COLCON_WS, colcon_pkg_path)

    # check package path existence
    if not os.path.exists(colcon_pkg_path):
        print('package path %s does not exists'%(colcon_pkg_path))
        sys.exit(-1)

    # running colcon cmake to create project files
    temp_build_path = os.path.join(CURRENT_COLCON_WS, WS_BUILD_DIR_NAME, '.temp_build')
    if os.path.exists(temp_build_path):
      shutil.rmtree(temp_build_path)    
    os.makedirs(temp_build_path)
    colcon_cmake_config_cmd = 'colcon build --packages-select {} --cmake-force-configure --cmake-args -G"Eclipse CDT4 - Unix Makefiles" -B{}'.format(colcon_pkg, temp_build_path)
    print('Creating project files with command:\n"{}"'.format(colcon_cmake_config_cmd))
    try:
      process = subprocess.run(colcon_cmake_config_cmd, shell=True, check=True, stdout=subprocess.PIPE, universal_newlines=True)
    except subprocess.CalledProcessError as e:
      print(e.output)  

    # extract include paths from eclipse files produced by cmake
    cproject_path = os.path.join(temp_build_path, '.cproject')
    if not os.path.exists(cproject_path):
      print('Failed to create .cproject file')
      shutil.rmtree(temp_build_path)
      sys.exit(-1)
      
    cproject_tree = ET.parse(cproject_path)
    cproject_root = cproject_tree.getroot()
    include_entry_list = []
    kind_attrib_name = 'kind'
    kind_attrib_val = 'inc'
    for pathentry in cproject_root.iter('pathentry'):
      if kind_attrib_name in pathentry.attrib and kind_attrib_val == pathentry.attrib[kind_attrib_name]:
        include_entry_list.append(pathentry.attrib)
        #print('Found include entry {}'.format(pathentry.attrib))    

    # remove temp build
    print('removing temp path {}'.format(temp_build_path))
    shutil.rmtree(temp_build_path)

    # add include paths to template .cproject file
    cproject_tree = ET.parse(os.path.join(ECLIPSE_TEMPLATE_PATH,ECLIPSE_TEMPLATE_CPROJECT_FILE))
    cproject_root = cproject_tree.getroot()
    option_attrib_name='id'
    option_attrib_val = 'gnu.cpp.compiler.option.include.paths'
    option_elmts = []
    for elmt in cproject_root.iter('option'):
      option_elmts.append(elmt)

    option_elmts = [elmt for elmt in option_elmts if (option_attrib_name in elmt.attrib and option_attrib_val == elmt.attrib[option_attrib_name]) ]

    if len(option_elmts) == 0:
      print('Found no "{}" elements with attrib "{}={}"'.format('option', option_attrib_name, option_attrib_val) )
      sys.exit(-1)

    list_opt_elmt_attribs = {'builtIn':'false', 'value':''}
    list_opt_elmt_name = 'listOptionValue'
    for incl_entry in include_entry_list:
      list_opt_elmt_attribs['value'] = incl_entry['include']
      list_opt_elmt = ET.SubElement(option_elmts[0],list_opt_elmt_name, attrib=list_opt_elmt_attribs)
      list_opt_elmt.tail = '\n'
    
    ## saving modified template into new .cproject file
    cproject_path = os.path.join(ECLIPSE_TEMPLATE_PATH,ECLIPSE_CPROJECT_FILE)
    cproject_tree.write(cproject_path, encoding='utf-8', xml_declaration=False)
    
    ## write xml declarations at the top of the file
    with open(cproject_path,'r+') as f:
      xml_context = f.read()
      f.seek(0,0)
      f.write(CPROJECT_XML_DECLARATIONS + xml_context)

        
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



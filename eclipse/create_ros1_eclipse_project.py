#!/usr/bin/env python3
import os
import sys
import subprocess
import shutil
import xml.etree.ElementTree as ET

HOME_VAR = 'HOME'
WORSPACE_VAR = 'ROS_WORKSPACE'
ROS_DISTRO_VAR = 'ROS_DISTRO'
ROS_DEVEL_CONFIG_PATH = os.path.join(os.path.expandvars('$HOME'), os.path.basename('ros_development_config'))

WS_INSTALL_DIR_NAME = 'install'
WS_BUILD_DIR_NAME = 'build'
WS_ECLIPSE_PROJECTS_DIR_NAME = 'projects'
WS_SRC_DIR_NAME = 'src'
WS_INSTALL_DIR_NAME = 'install'
ROS_DISTRO_PATH_TEMPLATE = '/opt/ros/ROS_DISTRO'

ECLIPSE_TEMPLATE_PATH = os.path.join(ROS_DEVEL_CONFIG_PATH , 'eclipse' ,'project_templates/ros1')
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
        print('Needs the ROS package name')
        sys.exit(-1)
        
    pkg_name = sys.argv[1]
    
    # get ws env info
    WS_DIR = ''
    WS_ECLIPSE_PROJECTS_PATH = ''
    if WORSPACE_VAR not in os.environ :
        print('ROS WS was not found')
        sys.exit(-1)

    WS_DIR = os.environ[WORSPACE_VAR].split(':')[0]
    print(WS_DIR)
    WS_ECLIPSE_PROJECTS_PATH = os.path.join(WS_DIR, WS_ECLIPSE_PROJECTS_DIR_NAME)

    # get ros distro
    if ROS_DISTRO_VAR not in os.environ :
        print('%s env var was not found'%(ROS_DISTRO_VAR))
        sys.exit(-1)
    ROS_DISTRO_PATH = ROS_DISTRO_PATH_TEMPLATE.replace('ROS_DISTRO',os.environ[ROS_DISTRO_VAR])
    
    # checking paths
    if not os.path.exists(WS_DIR):
        print('WS path %s does not exists'%(WS_DIR))
        sys.exit(-1)
        
    print('Found WS at %s' % (WS_DIR))    
        
    if not os.path.exists(WS_ECLIPSE_PROJECTS_PATH):
        os.mkdir(WS_ECLIPSE_PROJECTS_PATH)
        print('Created Eclipse projects directory at %s' % (WS_ECLIPSE_PROJECTS_PATH))

    # obtaining project path
    pkg_path=''
    try:
      cmd1 = 'rospack find %s'%(pkg_name)
      process = subprocess.run(cmd1 , shell=True, check=True, stdout=subprocess.PIPE, universal_newlines=True)
      pkg_path = process.stdout.split('\n')[0]
    except subprocess.CalledProcessError as e:
      print(e.output)
      sys.exit(-1)

    # check package path existence
    if not os.path.exists(pkg_path):
        print('package path %s does not exists'%(pkg_path))
        sys.exit(-1)

    # running build with cmake options to create project files
    build_cmd = 'catkin build --no-deps {} --force-cmake -G"Eclipse CDT4 - Unix Makefiles"'.format(pkg_name)
    print('Creating project files with command:\n"{}"'.format(build_cmd))
    try:
      process = subprocess.run(build_cmd, shell=True, check=True, stdout=subprocess.PIPE, universal_newlines=True)
    except subprocess.CalledProcessError as e:
      print(e.output)  

    # extract include paths from eclipse files produced by cmake
    cproject_path = os.path.join(WS_DIR,WS_BUILD_DIR_NAME,pkg_name,'.cproject')
    if not os.path.exists(cproject_path):
      print('Failed to create .cproject file')
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
    subs_tokens[ECLIPSE_PROJECT_NAME_TOKEN] = pkg_name
    subs_tokens[ECLIPSE_PROJECT_PATH_TOKEN] = pkg_path
    subs_tokens[ECLIPSE_WS_PATH_TOKEN] = WS_DIR
    subs_tokens[ECLIPSE_WS_INSTALL_PATH_TOKEN] = os.path.join(WS_DIR, WS_INSTALL_DIR_NAME)
    subs_tokens[ECLIPSE_ROS_DISTRO_PATH_TOKEN] = ROS_DISTRO_PATH
    
        # Read in the file
    for fpath in eclipse_files:
        with open(os.path.join(ECLIPSE_TEMPLATE_PATH,fpath), 'r') as f :
            filedata = f.read()
        
        # Replace the target string
        for token, str_rep in subs_tokens.items():
            filedata = filedata.replace(token, str_rep)
        
        # Write the file out again
        out_file_path = os.path.join(WS_ECLIPSE_PROJECTS_PATH,pkg_name,fpath)
        
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



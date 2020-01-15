#!/usr/bin/env python3
import os 
import json 
import sys
import subprocess

COLCON_VAR = 'COLCON_PREFIX_PATH'
WS_SRC_DIR_NAME = 'src'
WS_MIXIN_DIR_NAME = 'mixin'
WS_INSTALL_DIR_NAME = 'install'
MIXIN_FILE_NAME = 'skip.mixin'
INDEX_YAML_FILE_NAME = 'index.yaml'
SKIP_JSON_STR = '''{ "build":
    {
      "skip":
      {
        "packages-skip" : []
      }
    }
}'''

INDEX_YAML_STR = '''mixin:
    - skip.mixin'''

COLCON_BUILD_CMD = 'colcon build --symlink-install --mixin skip'

# required MIXIN fields
MIXIN_JSON_BUILD_FIELD = 'build'
MIXIN_JSON_SKIP_FIELD = 'skip'
MIXIN_JSON_PACKAGES_FIELD = 'packages-skip'


def get_package_skip_list(json_config_dict):

    if MIXIN_JSON_BUILD_FIELD not in json_config_dict:
        print('The \'%s\' field was not found in the mixin json dict' %
              (MIXIN_JSON_BUILD_FIELD))
        sys.exit(-1)

    build_dict = json_config_dict[MIXIN_JSON_BUILD_FIELD]
    if MIXIN_JSON_SKIP_FIELD not in build_dict:
        print('The \'%s\' field was not found in the mixin json dict' %
              (MIXIN_JSON_SKIP_FIELD))
        sys.exit(-1)

    skip_dict = build_dict[MIXIN_JSON_SKIP_FIELD]
    if MIXIN_JSON_PACKAGES_FIELD not in skip_dict:
        print('The \'%s\' field was not found in the mixin json dict' %
              (MIXIN_JSON_PACKAGES_FIELD))
        sys.exit(-1)
    packages_skip_list = skip_dict[MIXIN_JSON_PACKAGES_FIELD]
    if not isinstance(packages_skip_list, list):
        print('The field \'%s\' is not of type list' % (packages_skip_list))
        sys.exit(-1)
    return packages_skip_list


def find_mixin_files(paths_to_search):

    mixin_files_list = []
    sub_dirs = []
    for sp in paths_to_search:
        for root, dirs, files in os.walk(sp):
            for file in files:
                if file == (MIXIN_FILE_NAME):

                    full_file_path = os.path.join(root, file)
                    mixin_files_list.append(full_file_path)
                    print('Found mixin file in dir %s' % (full_file_path))
            if len(dirs) > 0:
                sub_dirs += [os.path.join(root, d) for d in dirs]

    if len(sub_dirs) > 0:
        new_mixin_files_list = find_mixin_files(sub_dirs)
        mixin_files_list += new_mixin_files_list

    return mixin_files_list


def create_mixin_dict(skip_pkg_list):
    skip_pkg_list = list(dict.fromkeys(skip_pkg_list))  # removing duplicates
    mixin_dict = eval(SKIP_JSON_STR)
    mixin_dict[MIXIN_JSON_BUILD_FIELD][MIXIN_JSON_SKIP_FIELD][MIXIN_JSON_PACKAGES_FIELD] = skip_pkg_list
    return mixin_dict


if __name__ == '__main__':

    # get path to current colcon workspace
    if COLCON_VAR not in os.environ:
        print('The env variable %s has not been set' % (COLCON_VA))
        sys.exit(-1)

    colcon_install_path = os.environ[COLCON_VAR]
    colcon_ws_path = colcon_install_path.replace('/' + WS_INSTALL_DIR_NAME, '')
    colcon_src_path = colcon_install_path.replace(WS_INSTALL_DIR_NAME, WS_SRC_DIR_NAME)
    colcon_mixin_path = colcon_install_path.replace(WS_INSTALL_DIR_NAME, WS_MIXIN_DIR_NAME)

    # getting all mixin files
    mixin_files = find_mixin_files([colcon_src_path])

    # getting all lists
    skip_pkg_list = []
    for mxf in mixin_files:
        data = {}
        with open(mxf, 'r') as json_file:
            print('\tFound mixin file \'%s\'' % (mxf))
            data = eval(json_file.read().replace('\n', ''))
        temp_list = get_package_skip_list(data)
        skip_pkg_list += temp_list

    skip_mixin_dict = create_mixin_dict(skip_pkg_list)

    # check mixin dir existence
    if not os.path.exists(colcon_mixin_path):
        os.mkdir(colcon_mixin_path)

    # create index file
    with open(os.path.join(colcon_mixin_path, INDEX_YAML_FILE_NAME), 'w') as outfile:
        outfile.write(INDEX_YAML_STR)

    skip_mixin_file_path = os.path.join(
        colcon_ws_path, 'mixin', MIXIN_FILE_NAME)
    with open(skip_mixin_file_path, 'w') as outfile:
        json.dump(skip_mixin_dict, outfile,  sort_keys=True, indent=2)
    print('Wrote workspace mixin file to path %s' % (skip_mixin_file_path))
    
    # addin mixin
    cmds = [('cd %s'%(colcon_ws_path),True),
            ('colcon mixin add skip file://' + os.path.join(colcon_mixin_path, INDEX_YAML_FILE_NAME), False),
            ('colcon mixin update skip', True)]
    for cmd, is_req in cmds:
        try:
            process = subprocess.run(cmd, shell=True, check=True, stdout=subprocess.PIPE, universal_newlines=True)
        except subprocess.CalledProcessError as e:
            if is_req:
                print('Required cmd \'%s\' failed with error:'%(cmd))
                print(e.output)
                sys.exit(-1)
            else:
                print('Optional cmd \'%s\' failed, skipping'%(cmd))

    print('\nmixin \'skip\' completed, the following packages will be skipped during the build:\n%s'%(str(skip_pkg_list).replace(', ','\n')))
    print('!!!IMPORTANT!!! Run the following command to skip these packages during a build:\n\t%s'%(COLCON_BUILD_CMD))

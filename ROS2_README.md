### Create/Open a colcon workspace
+  Make sure that [colcon](https://colcon.readthedocs.io/en/released/user/installation.html) is installed.  
+  In a terminal run the following to create the **my_workspace** workspace and bring up the linux terminals configured to the newly created workspace

	```
	ros2_session dashing my_workspace -c
	```	        
+  If a catkin workspace already exist then just run the following to bring up the terminals configured to that workspace:
	```
	ros2_session dashing my_workspace
	```               
            
+ If another ROS2 distribution is installed on the local machine such as **eloquent**, then run:

	```
	ros2_session eloquent my_workspace
    ```

### List current catkin workspaces
+  In a terminal run the following command to list the current workspaces:
    ```
    ros2_session -l dashing
    ```
+ The output should look like this:
    ```
    workspace_1
    workspace_2
    .
    .
    .
    ```
### Create a colcon mixin to blacklist packages from the build
This feature is useful when the repositories in the workspace contain a mixture of ROS1 (catkin) and ROS2 (colcon) packages and the goal is to ignore the ROS1 packages from the build.
#### Resources:
- [repo](https://github.com/colcon/colcon-mixin-repository)
- [answers.ros.org](https://answers.ros.org/question/306624/ignore-package-in-colcon-but-not-catkin/)
- [doc](https://colcon.readthedocs.io/en/released/reference/verb/mixin.html)

#### Steps
- Add a `skin.mixin` file in a repo of your workspace `src` directory with a list of the packages that should be skipped
    ```
    {
      "build": {
        "skip": {
          "packages-skip": ["ros1_pkg1",
                            "ros1_pkg2",
                            "moveit_ros1",
                            ],
        }
      }
    }
    ```
- If you have multiple repositories with packages that should be ignore then add `skin.mixin` files there as well.
  with the packages from that repo that need to be ignored.
- Run the following command to add the skipped packages from all the `skin.mixin` files into a global mixin
    ```
    colcon_ws_setup
    ```
- The output from that should be as follows:
    ```
    .
    .
    .
    'ros1_pkg1'
    'ros1_pkg2'
    'moveit_ros1']
    !!!IMPORTANT!!! Run the following command to skip these packages during a build:
	    colcon build --symlink-install --mixin skip
    ROS-dashing[crs_ws]: ./colcon_env_setup.py 

    ```
- Build using the `skip` mixin
    ```
    colcon build --symlink-install --mixin skip
    ```

### Workspace Context Commands
#### Create Eclipse project
- From the workspace top level directory run the following cmd on a existing ros2 package **my_ros2_pkg**
    ```
    create_eclipse_ros2_proj my_ros2_pkg
    ```
- This will create the eclipse project files under the `projects` directory.
- Then in the "Eclipse CDT" IDE you can import as an "Existing Project Into Workspace" by browsing to this `projects` directory and selecting your ros2 package.



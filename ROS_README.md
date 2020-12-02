### Create a catkin workspace
+  Make sure that catkin-tools is installed.  
+  In a terminal run the following to create the **my_workspace** workspace and bring up linux terminals configured to the newly created workspace

	```
	ros_session kinetic my_catkin_workspace -c
	```	        
+  If a catkin workspace already exist then just run the following to bring up the terminals configured to that workspace:
	```
	ros_session kinetic my_catkin_workspace
	```               
            
+ If another ros distribution is installed on the local machine such as **groovy**, then run:

	```
	ros_session groovy my_catkin_workspace
	```

### List current catkin workspaces
+  In a terminal run the following command to list the current workspaces:
```
ros_session -l kinetic
```
  The output should look like this:
  ```
  ros catkin workspace: workspace_1
  ros catkin workspace: workspace_2
  	.
  	.
  	.
  ```
  If using another ros distro then type that distro name instead

### Workspace Context Commands
The following commands can be used within the context of a catkin workspace:

- Source the workspace from any location
    ```
    catkin_ws_source
    ```
    
- Create Eclipse Project  
    ```
    create_eclipse_proj [pkg]
    ```

    This creates eclipse project files in the `projects\pkg` directory of the workspace.  Then in the "Eclipse CDT" IDE you can import the project by selecting the "Existing Project Into Workspace" and then browsing to the `projects` directory and selecting your ROS package.
    
	

- CD into several useful catkin workspace locations:
  The following ROS locations can be cd'ed with the ```roscd``` command:
  - src: Catkin workpace source directory
  - ws:  Catkin workspace top level directory
  
  For instance:
    ```
    roscd ws
    ```
    Goes to the top level directory of your catkin workspace and
    
    ```
    roscd src
    ```
    Goes to the `src` directory of the catkin workspace

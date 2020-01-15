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

### Workspace Context Commands
The following commands can be used within the context of a catkin workspace:

- Source the workspace from any location
    ```
    catkin_ws_source
    ```
    
- Install [eclipsify](https://github.com/ethz-asl/eclipsify)  
    ```
    install_eclipsify
    ```
    This will download the eclipsify repository into your workspace.  You can then create eclipse projects for your packages by calling the following command:
    ```
    create_eclipse_projects
    ```
    This creates a `projects` directory in your workspace.  Then in the "Eclipse CDT" IDE you can import as an "Existing Project Into Workspace" by browsing to this `projects` directory and selecting you ros packages.
    
	

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

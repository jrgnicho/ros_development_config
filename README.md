## linux_config
Shell scripts for configuring the linux environment for ROS development

#### Setup Instructions
+  Clone the "linux_config" repository in your home directory by running the following command:  
	```		
	cd
	git clone https://github.com/jrgnicho/linux_config.git	
	```
+  Select the branch corresponding to your linux environment, for instance in linux **xenial** do:
	```
	cd ~/linux_config
	git checkout xenial
	```

+  Add the following line to your bash file ".bashrc":
	
	```
	source "$HOME/linux_config/general/setup.bash"
	```                 
 + Run your bash file
 	```
	source ~/.bashrc
	```
### Create a catkin workspace
+  Make sure that catkin-tools is installed.  
+  In a terminal run the following to create the **my_workspace** workspace and bring up linux terminals configured to the newly created workspace

	```
	ros_session kinetic my_catkin_workspace -c
	```	        
+  If a catkin workspace already exist then just run the following to bring up the terminals configured to the existing workspace:
	```
	ros_session kinetic my_catkin_workspace
	```
            
+  Also, pass the name of an existing terminal profile to bring up the terminals with that profile

	```
	ros_session kinetic my_catkin_workspace profile1
	```	        
           
            
+ If another ros released is installed on the local machine such as **groovy**, then run:

	```
	ros_session groovy my_catkin_workspace profile1
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

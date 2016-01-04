# linux_config
============
Shell scripts for configuring linux environment for ros

#### Instructions
============
+	Place the "linux_config" repo in your home directory by running the following on the terminal
		
		cd
		git clone https://github.com/jrgnicho/linux_config.git	

+	Add the following lines to your bash file ".bashrc":
	
```
               source "$HOME/linux_config/general/setup.bash"
```                 
                            
		
+       In a terminal run the following to create the **my_workspace** catkin workspace and bring up linux terminals configured to the newly created workspace

```
	        ros_session indigo my_catkin_workspace -c
```	        
+ 	If a catkin workspace already exist then just run the following to bring up the terminals configured to the existing workspace:
```
                ros_session indigo my_catkin_workspace
```
            
+       Also, pass the name of an existing terminal profile to bring up the terminals with that profile

```
	        ros_session indigo my_catkin_workspace profile1
```	        

            
            
+      If another ros released is installed on the local machine such as **groovy**, then run:

```
	       ros_session groovy my_catkin_workspace profile1
```

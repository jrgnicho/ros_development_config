## ROS Development Scripts
Various scripts for facilitating ROS and ROS2 development

#### Setup Instructions
+  Clone the "ros_development_config" repository in your home directory by running the following command:  
	```		
	cd
	git clone https://github.com/jrgnicho/ros_development_config.git	
	```
+  Select the branch corresponding to your linux environment, for instance in linux **bionic** do:
	```
	cd ~/ros_development_config
	```

+  Add the following line to your bash file ".bashrc":
	
	```
	source "$HOME/ros_development_config/general/setup.bash"
	```                 
 + Run your bash file
 	```
	source ~/.bashrc
	```
### ROS/catkin Tools
- [Description](ROS_README.md)

### ROS2/colcon Tools
- [Description](ROS2_README.md)
  
  
### Other features
  - [Debugging with Eclipse](gdb/README.md)

### Other Useful Tools
- Eclipse/ROS integration  
  - [eclipsify](https://github.com/ethz-asl/eclipsify)  


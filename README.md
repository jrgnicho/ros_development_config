linux_config
============
shell scripts for configuring linux environment for ros

Instructions
============
+	Place the "linux_config" repo in your home directory by running the following on the terminal
		
		cd
		git clone https://github.com/jrgnicho/linux_config.git	

+	Add the following lines to your bash file ".bashrc":
	
```
                 source "$HOME/linux_config/general/setup.bash"
```                 
                            
		
+       In a terminal run the following to bring up ros enabled terminals

```
	        ros_session hydro
```	        
	        
            
+       Alternatively, pass the name of an existing terminal profile to bring up the terminals with that profile

```
	        ros_session hydro profile1
```	        

            
            
+      If another ros released is installed on the local machine such as groovy, then run:

```
	       ros_session groovy profile1
```

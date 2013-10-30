linux_config
============
shell scripts for configuring linux environment for ros

Instructions
============
+	Place the "linux_config" repo in your home directory by running the following on the terminal
		
		cd
		git clone https://github.com/jrgnicho/linux_config.git	

+	Add the following lines to your bash file ".bashrc":

		# general settings
		source "$HOME/linux_config/general/setup.bash"

		# ros setup
		source "$HOME/linux_config/ros/hydro/setup.bash"


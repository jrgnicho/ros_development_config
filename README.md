linux_config
============
shell scripts for configuring linux environment for ros

Instructions
============
+	Add the following lines to your bash file ".bashrc":

		# general settings
		source "$HOME/linux_config/general/setup.bash"

		# ros setup
		source "$HOME/linux_config/ros/${ros_session_distro}/setup.bash"


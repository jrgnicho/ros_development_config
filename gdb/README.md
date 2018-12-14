## Eclipse C/C++ ROS

#### Prerequisites:
-	Install Eclipse CDT (Tested on mars only)
-	Install ROS
-	Create a catkin workspace
-	Install [eclipsify](https://github.com/ethz-asl/eclipsify)
-	Install all ROS and system dependencies required by your application in the caktin workspace using `rosdep` and `wstools`

#### Enable Debugging:
- Enable ptracing:  
  In linux 10.10 and greater, ptracing of non-child processes by non-root users is disabled by default. As a consequence, debugging with gdb through eclipse won't be possible.  To permanently allow it edit **/etc/sysctl.d/10-ptrace.conf** and change the line:
  
  `kernel.yama.ptrace_scope = 1`  
  
  To read  

  `kernel.yama.ptrace_scope = 0`
  
  For more on this issue see [here](https://askubuntu.com/questions/41629/after-upgrade-gdb-wont-attach-to-process)
 
#### Create Eclipse Projects  
- For **catkin-tools**
      - The `create_eclipse_projects` generates **.project** files for eclipse for each ros package
        ```
        create_eclipse_projects
        ```
        >> NOTE: This assumes that [eclipsify](https://github.com/ethz-asl/eclipsify) and catkin-tools have been previously installed
        
-	For **catkin_make**, cd into your catkin workspace directory and run the following:
  
   	```catkin_make -DCMAKE_BUILD_TYPE=Debug --force-cmake -G"Eclipse CDT4 - Unix Makefiles" ```
  - For more information on creating eclipse project files see the **Eclipse** section [here](http://wiki.ros.org/IDEs)

#### Eclipse CDT Setup:
-	Import Project:  

    - File->Import->General -> Existing Projects Into Workspace -> Browse to your catkin workspace “build” directory -> Finish
    - Check the projects that you'd like to add into the eclipse workspace and click "Finish".
    
-	Configure Project for c++11 or higher (optional) :
    - Enter the **Properties** window of any project.
    - Navigate to C/C++ General -> Preprocessor Include Path, Macros etcc
    - In the “Providers” tab, select and check the “CDT GCC Built-in Compiler Settings [Shared]” checkbox.
    - Check the **Use global provider shared between projects** and then click **Workspace Settings**
    - In the **Settings** window go into the **Discovery** tab.
    - Select **CDT GCC Buit-in Compiler Settings [Shared]**
    - Add `-std=c++11` at the end of the text in the **Command to get compiler specs** text box.
    - Click **Apply and Close** on all open windows.
   
- Turn off code analysis (optional)
    For some reason this feature doesn't work very well so it's preferable to turn it off.
    - Code Analysis Configuration: Properties -> C/C++ General -> Code Analysis and click “Configure Workspace Settings” in the “Code Analysis” panel.  
    -	In the Code Analysis Window uncheck everything except for the “Potential Programming Problems” checkbox then hit “Apply” and “OK”.


#### Eclipse CDT Debugging  
Debugging requires that you build your project in *Debug* mode, for instance you would run the following command
to build your full catkin workspace in *Debug*:
```
catkin build --cmake-args -DCMAKE_BUILD_TYPE=Debug
```

Alternatively, you can change the build command in the eclipse project and add the `--cmake-args -DCMAKE_BUILD_TYPE=Debug` part to the build command in the project **Properties** (eclipsify setup only)

There are multiple debugging modes supported by Eclipse CDT, the following sections describe how to create some of these debugging configuraions:
-	C/C++ Attach To process:
    This mode will attach the _gdb debugger_ to an already running process:
    - Go to **Run** -> **Debug Configuration**
    - Double click on **C/C++ Attach to Application** to create a new configuration
    - Edit the name of the configuration if desired
    - In the **C/C++ Application:** section, browse to the application or binary that you intend to debug.  These are usually located in the **devel** directory of the catkin workspace.
    - Now go to the **Debugger** tab and locate the **GDB command line** textbox.
    - Click **Browse** and locate the *gdbinit* file located in the **gdb** directory of this repo.  This will apply formatting to the gdb debugger output.  
    - Click **Apply**
    - Now run your application externally (in the terminal window for example)
    - Back in Eclipse, click **Debug** and then a window should come up with a list of selectable processes including ros nodes. Select the process you'd like to attach to from the list.
    - At this point Eclipse will attach to that process and will go into the Debug context.
    - You may have to click the "Resume" green arrow to let the application run.
    
-   C/C++ Remote Application:
    This mode allows starting and debugging ros nodes and launch files
    - Go to **Run** -> **Debug Configuration**
    - Double click on **C/C++ Remote Application** to create a new configuration
    - Edit the name of the configuration if desired.
    - In the **C/C++ Application:** section, browse to the application or binary that you intend to debug.  These are usually located in the **devel** directory of the catkin workspace.
    - Do the same for on the **Remote Absolute File Path for C/C++ Application** textbox.
    - In the **Commands to execute before application** textbox, enter the full rosrun or roslaunch command that starts the node you intend to debug.
    - Now go to the **Debugger** tab and locate the **GDB command line** textbox.
    - Click **Browse** and locate the *gdbinit* file located in the **gdb** directory of this repo.  This will apply formatting to the gdb debugger output.  
    - Go to the **Gdbserver Settings** subtab and make a note of the port number.
    - Click **Apply** and then **Close**
    - Follow for launch file:
        - If debugging a ros launch file then it'll be necessary to add a 'launch-prefix' attribute to the node.
        - Open your launch file and locate the <node> tag for your node and set the *launch-prefix* as follows: `launch-prefix="gdbserver localhost:<port number>"`. Remember to replace **<port number>** with the port number observed in the **GdbServer Settings** subtab.
    - Follow for just a ros node:
        - Just run your node with the `--prefix` argument as follows: 
            ```
            rosrun --prefix gdbserver localhost:<port number> my_pkg my_ros_node
            ```
            Obviously you would enter the port number observed in the **GdbServer Settings** subtab.
    - Go back to the **Debug Configurations** window, select your newly created configuration and click debug.
    - At this point eclipse will run your program and go into the **Debug** Context.



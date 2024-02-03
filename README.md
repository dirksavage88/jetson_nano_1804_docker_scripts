# jetson_nano_1804_docker_scripts
Bring up ROS 2 foxy and docker on the original Jetson Nano 

This repo is assuming you are using a recent version of Jetpack (tested on Jetpack v4.6.x or v4.7.x) on the original Jetson Nano.

If you have not installed/configured the Nvidia Contaainer Toolkit AND Isaac ROS Common **->>>** **STOP** **>>>** **these install scripts will not work until you have successfully installed the Nvidia Container Toolkit and ran the 'run_dev.sh' script in Isaac ROS Common:** https://github.com/dirksavage88/isaac_ros_common

Step 1) Clone the repo into your home directory.

Step 2) Copy all install scripts into ~/workspaces/isaac_ros-dev. You should already have this folder if you have followed the Issac ROS common repo instructions.

Step 3) change directories to ~/workspaces/isaac_ros-dev and run the command 'sudo chmod +rwx *.sh'

Step 4) run the command './jetson_nano_bringup.sh', this takes a while the first time through

Step 5) Ensure you have the isaac ros docker image listed by running 'docker image ls'

Step 6) run the command './ros-nodes_entrypoint.sh'*

Step 7) Confirm the running container 'docker ps'

Step 8) Confirm all topics are publishing via ROS 2 on a workstation using command line, Rviz2, or Foxglove studio


_You may need to substitute your own ROS 2 camera driver if  you are not using a usb single image stereo camera output (libuvc based) and using MIPI cameras instead. Also the stereo splitter node (side_x_side) is only for cameras that output a single output image that needs to be split._

Ensure to calibrate your camera and place the calibration files (*.yaml) in the config directory before running


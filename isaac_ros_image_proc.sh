#!/bin/bash
echo "Starting isaac ros image proc"
source /opt/ros/foxy/setup.bash
source install/setup.bash
ros2 run isaac_ros_image_proc isaac_ros_image_proc

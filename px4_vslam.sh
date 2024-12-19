#!/bin/bash
echo "Starting px4_vslam Node"
source /opt/ros/foxy/setup.bash
source install/setup.bash
ros2 run px4_vslam vio_transform

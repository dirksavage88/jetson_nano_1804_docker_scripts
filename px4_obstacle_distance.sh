#!/bin/bash
echo "Starting Multi Array Distance Node"
source /opt/ros/foxy/setup.bash
source install/setup.bash
ros2 run jetson_obs_distance px4_obs_distance

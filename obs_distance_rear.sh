#!/bin/bash
echo "Starting Obstacle Distance Node"
# Open up the i2c permissions
sudo usermod -aG i2c $USER

source /opt/ros/foxy/setup.bash
source install/setup.bash
ros2 run jetson_obs_distance jetson_obs_distance --ros-args -p i2c_bus:=0 -p i2c_addr:=86 -p obs_index_offset:=36

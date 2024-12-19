#!/bin/bash
echo "Starting isaac ros vslam"
source /opt/ros/foxy/setup.bash
source install/setup.bash
ros2 launch isaac_ros_visual_slam isaac_ros_slam_visualize.launch.py

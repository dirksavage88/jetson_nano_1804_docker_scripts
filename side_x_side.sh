#!/bin/bash
echo "Starting side-by-side stereo splitter"
source /opt/ros/foxy/setup.bash
source install/setup.bash
ros2 run side_x_side_stereo side_x_side_stereo_node --ros-args -p input_image_topic:=/image_mono -p image_encoding:=mono8 -p right_cam_calibration_file:=file:///workspaces/isaac_ros-dev/ros_ws/side_x_side_stereo/config/right.yaml -p left_cam_calibration_file:=file:///workspaces/isaac_ros-dev/ros_ws/side_x_side_stereo/config/left.yaml


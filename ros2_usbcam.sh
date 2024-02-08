#!/bin/bash
echo "Starting ros2 usb cam driver"
source install/setup.bash
ros2 run usb_camera_driver usb_camera_driver_node --ros-args -p image_width:=640 -p image_height:=240 -p fps:=60 -p camera_calibration_file:=file:///workspaces/isaac_ros-dev/ros_ws/ros2_usb_camera/config/camera.yaml


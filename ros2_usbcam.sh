#!/bin/bash
echo "Starting ros2 usb cam driver"
source install/setup.bash
ros2 run usb_camera_driver usb_camera_driver_node


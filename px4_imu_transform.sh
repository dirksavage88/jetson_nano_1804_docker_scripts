#!/bin/bash
echo "Starting px4 imu transforms"
source install/setup.bash
ros2 run imu_transform imu_transform

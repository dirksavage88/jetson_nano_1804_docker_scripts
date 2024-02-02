#!/bin/bash
echo "starting static transforms"
source install/setup.bash
ros2 run tf2_ros static_transform_publisher 0.07 0.05 -0.01 0 0 0 base_link input_base_frame & ros2 run tf2_ros static_transform_publisher -0.07 -0.08 0.01 0 0 0 input_base_frame imu


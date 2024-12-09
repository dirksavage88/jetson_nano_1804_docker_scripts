#!/bin/bash
echo "Starting Multi Array Distance Node"
# Open up the i2c permissions
#sudo groupadd i2c
#sudo chown :i2c /dev/i2c-0
#sudo chmod g+rw /dev/i2c-0
#sudo usermod -aG i2c $USER
sudo groupadd gpio
sudo usermod -aG gpio $USER
sudo chgrp gpio /sys/class/gpio/export
sudo chgrp gpio /sys/class/gpio/unexport

#sudo chgrp gpio /sys/class/gpio/*/direction
#sudo chgrp gpio /sys/class/gpio/*/value

sudo chmod 775 /sys/class/gpio/export
sudo chmod 775 /sys/class/gpio/unexport
#sudo chmod 775 /sys/class/gpio/*/direction
#sudo chmod 775 /sys/class/gpio/*/value
source /opt/ros/foxy/setup.bash
source install/setup.bash
ros2 run jetson_obs_distance vl53_set_address --ros-args -p num_sensors:=4 -p i2c_bus:=0 -p starting_gpio:=12

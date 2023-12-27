#!/bin/bash

CWD=$(pwd)
# Update via apt

sudo apt update
sudo apt install -y \
		apt-utils \
		gcc-arm-none-eabi \
		python3-pip \
		git \
		ninja-build \
		pkg-config \
		gcc \
		g++ \
		systemd \

# Common Pip packages
sudo pip3 install Jetson.GPIO meson pyserial pymavlink dronecan
# Jtop for analyzing performance and thermals
echo "Installing jtop..."
sudo pip3 install -U jetson-stats

# VCS tool
sudo pip3 install vcstool

# Configure environment
sudo systemctl stop nvgetty
sudo systemctl disable nvgetty

sudo apt remove modemmanager -y
sudo usermod -a -G dialout $USER

sudo groupadd -f -r gpio
sudo usermod -a -G gpio $USER
sudo usermod -a -G i2c $USER
sudo usermod -aG docker $USER && newgrp docker

sudo cp 99-gpio.rules /etc/udev/rules.d/
sudo udevadm control --reload-rules && sudo udevadm trigger

# Install jetson fan control and run the setup script (old nano fan)
echo "Installing jetson fan control package..."
git clone https://github.com/Pyrestone/jetson-fan-ctl.git
cd ~/jetson-fan-ctl && sudo ./install.sh

echo "installing curl"
sudo apt install -y curl
sudo apt-get install -y nvidia-container-toolkit
sudo apt-get install -y nvidia-docker2

sudo tee -a /etc/docker/daemon.json > /dev/null <<EOT 
{
    "runtimes": {
        "nvidia": {
            "path": "/usr/bin/nvidia-container-runtime",
            "runtimeArgs": []
        }
    },
    "default-runtime": "nvidia"
}
EOT

sudo systemctl daemon-reload && sudo systemctl restart docker

# GIT LFS, multimedia & CUDA dependency libraries
sudo apt install -y git-lfs
sudo apt install -y nvidia-l4t-jetson-multimedia-api
sudo apt install -y nvidia-cudnn8
sudo apt install -y libcufft-dev-10-2 

# setting up ROS 2 workspace
mkdir -p $HOME/workspaces/isaac_ros-dev/ros_ws 
cd $HOME/workspaces/isaac_ros-dev/ros_ws && sudo vcs import --recursive < $CWD/jetson_apps.repo
echo "Done installing ros2 workspace..."
echo "Setup the stable repo and GPG key..."
distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
   && curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add - \
   && curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list
echo "Experimental features..."
curl -s -L https://nvidia.github.io/nvidia-container-runtime/experimental/$distribution/nvidia-container-runtime.list | sudo tee /etc/apt/sources.list.d/nvidia-container-runtime.list
echo "Starting ros 2 foxy docker bringup..."
cd $HOME/workspaces/isaac_ros-dev/ros_ws/isaac_ros_apriltag/ && git-lfs pull
cd $HOME/workspaces/isaac_ros-dev/ros_ws/isaac_ros_visual_slam/ && git-lfs pull
cd $HOME/workspaces/isaac_ros-dev/ros_ws/isaac_ros_image_pipeline/ && git-lfs pull
cd $HOME/workspaces/isaac_ros-dev/ros_ws/isaac_ros_common/ && git-lfs pull

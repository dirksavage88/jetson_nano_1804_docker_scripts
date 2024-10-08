#!/bin/bash

ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

function print_color {
    tput setaf $1
    echo "$2"
    tput sgr0
}

function print_error {
    print_color 1 "$1"
}

function print_warning {
    print_color 3 "$1"
}

function print_info {
    print_color 2 "$1"
}

# Read and parse config file if exists
#echo "reading config file at $ROOT"
#. "${ROOT}/.isaac_ros_common-config"

ISAAC_ROS_DEV_DIR="$HOME/workspaces/isaac_ros-dev"


ON_EXIT=()
function cleanup {
    for command in "${ON_EXIT[@]}"
    do
        $command
    done
}
trap cleanup EXIT

pushd . >/dev/null
cd $ROOT
ON_EXIT+=("popd")

# Prevent running as root.
if [[ $(id -u) -eq 0 ]]; then
    print_error "This script cannot be executed with root privileges."
    print_error "Please re-run without sudo and follow instructions to configure docker for non-root user if needed."
    exit 1
fi

# Check if user can run docker without root.
RE="\<docker\>"
if [[ ! $(groups $USER) =~ $RE ]]; then
    print_error "User |$USER| is not a member of the 'docker' group and cannot run docker commands without sudo."
    print_error "Run 'sudo usermod -aG docker \$USER && newgrp docker' to add user to 'docker' group, then re-run this script."
    print_error "See: https://docs.docker.com/engine/install/linux-postinstall/"
    exit 1
fi

# Check if able to run docker commands.
if [[ -z "$(docker ps)" ]] ;  then
    print_error "Unable to run docker commands. If you have recently added |$USER| to 'docker' group, you may need to log out and log back in for it to take effect."
    print_error "Otherwise, please check your Docker installation."
    exit 1
fi

# Check if git-lfs is installed.
if [[ -z "$(git lfs)" ]] ; then
    print_error "git-lfs is not insalled. Please make sure git-lfs is installed before you clone the repo."
    exit 1
fi

# Check if all LFS files are in place
git rev-parse &>/dev/null
if [[ $? -eq 0 ]]; then
    LFS_FILES_STATUS=$(cd $ISAAC_ROS_DEV_DIR && git lfs ls-files | cut -d ' ' -f2)
    for (( i=0; i<${#LFS_FILES_STATUS}; i++ )); do
        f="${LFS_FILES_STATUS:$i:1}"
        if [[ "$f" == "-" ]]; then
            print_error "LFS files are missing. Please re-clone the repo after installing git-lfs."
            exit 1
        fi
    done
fi

PLATFORM="$(uname -m)"

# TODO: do we want to rename the container?
BASE_NAME="isaac_ros_dev-$PLATFORM"
CONTAINER_NAME="$BASE_NAME"

# Map host's display socket to docker
DOCKER_ARGS+=("-v /tmp/.X11-unix:/tmp/.X11-unix")
DOCKER_ARGS+=("-v $HOME/.Xauthority:/home/admin/.Xauthority:rw")
DOCKER_ARGS+=("-e DISPLAY")
DOCKER_ARGS+=("-e NVIDIA_VISIBLE_DEVICES=all")
DOCKER_ARGS+=("-e NVIDIA_DRIVER_CAPABILITIES=all")
DOCKER_ARGS+=("-e FASTRTPS_DEFAULT_PROFILES_FILE=/usr/local/share/middleware_profiles/rtps_udp_profile.xml")
DOCKER_ARGS+=("-e ROS_DOMAIN_ID")

if [[ $PLATFORM == "aarch64" ]]; then
    DOCKER_ARGS+=("-v /usr/local/cuda-10.2/targets/aarch64-linux/lib/:/usr/local/cuda-10.2/targets/aarch64-linux/lib/")
    DOCKER_ARGS+=("-v /usr/bin/tegrastats:/usr/bin/tegrastats")
    DOCKER_ARGS+=("-v /tmp/argus_socket:/tmp/argus_socket")
    DOCKER_ARGS+=("-v /usr/lib/aarch64-linux-gnu/tegra:/usr/lib/aarch64-linux-gnu/tegra")
    DOCKER_ARGS+=("-v /usr/src/jetson_multimedia_api:/usr/src/jetson_multimedia_api")
    DOCKER_ARGS+=("-v /opt/nvidia/nsight-systems-cli:/opt/nvidia/nsight-systems-cli")
    DOCKER_ARGS+=("--pid=host")
    DOCKER_ARGS+=("--group-add=i2c")

    # If jtop present, give the container access
    if [[ $(getent group jtop) ]]; then
        DOCKER_ARGS+=("-v /run/jtop.sock:/run/jtop.sock:ro")
        JETSON_STATS_GID="$(getent group jtop | cut -d: -f3)"
        DOCKER_ARGS+=("--group-add $JETSON_STATS_GID")

    fi
fi

# Optionally load custom docker arguments from file
#DOCKER_ARGS_FILE="$ROOT/.isaac_ros_dev-dockerargs"
#if [[ -f "$DOCKER_ARGS_FILE" ]]; then
#    print_info "Using additional Docker run arguments from $DOCKER_ARGS_FILE"
#    readarray -t DOCKER_ARGS_FILE_LINES < $DOCKER_ARGS_FILE
#    for arg in "${DOCKER_ARGS_FILE_LINES[@]}"; do
#        DOCKER_ARGS+=($(eval "echo $arg | envsubst"))
#    done
#fi

# Run container from image
print_info "Running $CONTAINER_NAME"

CONTAINER_WS_DIR="/workspaces/isaac_ros-dev"

docker run \
	--detach \
	--rm \
    --privileged \
    --network host \
    ${DOCKER_ARGS[@]} \
    -v $ISAAC_ROS_DEV_DIR:$CONTAINER_WS_DIR \
    -v /dev/*:/dev/* \
    -v /etc/localtime:/etc/localtime:ro \
    --name "$CONTAINER_NAME" \
    --runtime nvidia \
    --user="admin" \
    --entrypoint $CONTAINER_WS_DIR/ros-nodes_entrypoint.sh \
    --workdir $CONTAINER_WS_DIR \
    $BASE_NAME \
    /bin/bash

# Attach to running container

echo "Attaching to running container: ros2 usb cam"
docker exec -d -u admin --workdir $CONTAINER_WS_DIR/ros_ws $CONTAINER_NAME $CONTAINER_WS_DIR/ros2_usbcam.sh

echo "Attaching to running container: Image proc"
docker exec -d -u admin --workdir $CONTAINER_WS_DIR/ros_ws $CONTAINER_NAME $CONTAINER_WS_DIR/isaac_ros_image_proc.sh

echo "Attaching to running container: stereo split"
docker exec -d -u admin --workdir $CONTAINER_WS_DIR/ros_ws $CONTAINER_NAME $CONTAINER_WS_DIR/side_x_side.sh

echo "Attaching to running container: static tf"
docker exec -d -u admin --workdir $CONTAINER_WS_DIR/ros_ws $CONTAINER_NAME $CONTAINER_WS_DIR/static_tf.sh

echo "Attaching to running container: VSLAM"
docker exec -d -u admin --workdir $CONTAINER_WS_DIR/ros_ws $CONTAINER_NAME $CONTAINER_WS_DIR/isaac_ros_vslam.sh

echo "Attaching to running container: px4_vslam"
docker exec -d -u admin --workdir $CONTAINER_WS_DIR/ros_ws $CONTAINER_NAME $CONTAINER_WS_DIR/px4_vslam.sh

echo "Processes started, exiting."

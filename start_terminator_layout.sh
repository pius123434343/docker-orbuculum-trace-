#!/bin/bash

# Remove the existing "orbtrace-container" if it already exists
if docker ps -a --format '{{.Names}}' | grep -Eq "^orbtrace-container\$"; then
    echo "An existing container named 'orbtrace-container' is being removed..."
    docker stop orbtrace-container >/dev/null 2>&1
    docker rm orbtrace-container >/dev/null 2>&1
    echo "Container 'orbtrace-container' successfully removed."
fi

# Build the Docker image
echo "Building the Docker image 'orbtrace'..."
docker build -t orbtrace .

# Start the Docker container
echo "Starting a new container 'orbtrace-container'..."
docker run -itd --privileged \
    -p 2000:2000/tcp \
    -v /dev/bus/usb:/dev/bus/usb \
    -v /home/birop/Downloads:/home/birop/Downloads \
    --name orbtrace-container \
    orbtrace

# Retrieve the container ID
CONTAINER_ID=$(docker ps -qf "name=orbtrace-container")

# Launch Terminator with manual splits using xdotool
echo "Launching Terminator with manual splits..."
terminator &

sleep 2  # Wait for Terminator to launch

# Split and assign commands to panes
xdotool key Ctrl+Shift+O  # Horizontal split
sleep 0.5
xdotool type "docker exec -it ${CONTAINER_ID} bash -c 'blackmagic -v 5; sleep infinity'"
sleep 0.5
xdotool key Return
sleep 1

xdotool key Ctrl+Shift+E  # Vertical split
sleep 0.5
xdotool type "docker exec -it ${CONTAINER_ID} bash -c 'orbuculum -O \"-T 4\" -m 500; exec bash'"
sleep 0.5
xdotool key Return
sleep 1

xdotool key Ctrl+Shift+O  # Horizontal split
sleep 0.5
xdotool type "docker exec -it ${CONTAINER_ID} bash -c 'gdb-multiarch; exec bash'"
sleep 0.5
xdotool key Return
sleep 1

xdotool key Ctrl+Shift+E  # Vertical split
sleep 0.5
xdotool type "docker exec -it ${CONTAINER_ID} bash"
sleep 0.5
xdotool key Return


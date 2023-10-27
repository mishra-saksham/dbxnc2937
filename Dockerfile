# Start with the base image
FROM dorowu/ubuntu-desktop-lxde-vnc

# Update the package repositories
RUN apt-get update

# Add any additional customizations or installations you need here

# Mount the /dev/shm directory from the host to the same location inside the container
VOLUME /dev/shm:/dev/shm

# Expose port 6080
EXPOSE 6080

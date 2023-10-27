# Base image
FROM dorowu/ubuntu-desktop-lxde-vnc:bionic

# Install necessary packages
RUN apt-get update && apt-get install -y novnc websockify

# Expose ports
EXPOSE 80

# Set up entrypoint
ENTRYPOINT ["websockify", "0.0.0.0:80", "--web", "/usr/share/novnc/"]

# Set the default command
CMD ["bash"]

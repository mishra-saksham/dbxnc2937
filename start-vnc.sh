#!/bin/bash

set -e

# make sure they own their home directory
#chown -R ubuntu ~ubuntu ; chgrp -R ubuntu ~ubuntu

# set the passwords for the user and the x11vnc session
# based on environment variables (if present), otherwise roll with
# the defaults from the Dockerfile build. 
#

if [ ! -z $UBUNTUPASS ] 
then
  echo "ubuntu:$UBUNTUPASS" | chpasswd
fi

if [ ! -z $VNCPASS ] 
then
  echo "ubuntu:$UBUNTUPASS" | chpasswd
  echo $VNCPASS
  /usr/bin/vncpasswd -f <<< $VNCPASS > "/tmp/passwd"
  chmod go-rw /tmp/passwd
  chown ubuntu:ubuntu /tmp/passwd
fi

service xrdp start &

rm -f /home/ubuntu/.Xaut*

sudo -u ubuntu \
       	/usr/bin/tigervncserver -depth 24 -geometry 1920x1080  -passwd /tmp/passwd -SecurityTypes X509Vnc,VncAuth -X509Key /config/self.key -X509Cert /config/self.crt  &

sleep 2
sudo -u ubuntu \
	pkill vncconfig 

echo "#!/bin/bash
cd /noVNC
./utils/novnc_proxy --listen $LISTENPORT --vnc localhost:5901 --cert /noVNC/self.pem --ssl-only " > /noVNC/start_proxy_command 
chmod ugo+x /noVNC/start_proxy_command
sudo -u ubuntu /noVNC/start_proxy_command &

bash

wait

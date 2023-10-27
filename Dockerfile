FROM ubuntu:20.04
ENV DEBIAN_FRONTEND noninteractive
ENV HOME /root
###
# Deskstop/BASE noVNC
###
#RUN apt update && DEBIAN_FRONTEND=noninteractive apt install -y lubuntu-desktop
RUN apt update && DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -y

RUN apt-get update && apt-get -yq dist-upgrade && \
    apt-get install -yq --no-install-recommends \
    wget \
    curl \
    bzip2 \
    ca-certificates \
    apt-utils \
    software-properties-common \
    openssl \
    tini \
    pwgen \
    sudo \
    netcat \
    vim-tiny \
    net-tools \
    sed \
    jq \
    npm \
    unzip \
    python3-pip \
    build-essential

RUN apt-get install -y \
    iputils-ping \
    lxde \
    lxde-common \
    xterm \
    xfce4-terminal \
    firefox

# create an ubuntu user who cannot sudo
RUN useradd --create-home --shell /bin/bash --user-group ubuntu
RUN echo "ubuntu:unwantedfox01" | chpasswd

RUN apt-get install -y \
    tigervnc-standalone-server \
    tigervnc-xorg-extension 
ADD config /config

# Build noVNC
ARG NOVNC_VERSION=1.4.0
ARG NOVNC_URL=https://github.com/novnc/noVNC/archive/refs/tags/v${NOVNC_VERSION}.tar.gz
RUN npm install clean-css-cli -g

# packages websockify will need
RUN pip3 install \
    numpy \
    jwcrypto

# Install noVNC
RUN mkdir /noVNC && \
    curl -# -L ${NOVNC_URL} | tar -xz --strip 1 -C /noVNC
COPY config/index.html /noVNC/index.html

WORKDIR /tmp
# Install websockify
RUN wget https://github.com/novnc/websockify/archive/refs/tags/v0.11.0.tar.gz -O /tmp/websockify.tgz && \
    tar -zxf /tmp/websockify.tgz && \
    rm /tmp/websockify.tgz && \
    cd /tmp/websockify*  && \
    python3 setup.py install

# Set version of CSS and JavaScript file URLs
RUN sed "s/UNIQUE_VERSION/$(date | md5sum | cut -c1-10)/g" -i /noVNC/index.html

RUN cp /config/self.pem /noVNC/

# Set environment variables.
ENV DISPLAY_WIDTH=1920 \
    DISPLAY_HEIGHT=1080 \
    SECURE_CONNECTION=1 \
    SECURE_CONNECTION_VNC_METHOD=SSL \
    SECURE_CONNECTION_CERTS_CHECK_INTERVAL=60 \
    WEB_LISTENING_PORT=5800 \
    VNC_LISTENING_PORT=5900
EXPOSE 6080
##
# END Deskstop/BASE noVNC
###




# Configure container startup
RUN chown ubuntu:ubuntu /noVNC/self.pem


### RDP ###
RUN apt install -y xrdp 
RUN touch /var/log/xrdp-sesman.log && touch /var/log/xrdp.log
RUN chmod +66 /var/log/xrdp-sesman.log 
RUN chmod +66 /var/log/xrdp.log
RUN mkdir /var/run/xrdp
RUN chown xrdp:xrdp /var/run/xrdp
RUN chmod +777 /var/run/xrdp

# we need the ssl cert to be in the right place
RUN rm /etc/xrdp/cert.pem /etc/xrdp/key.pem
RUN cp /config/cert.pem /etc/xrdp/
RUN cp /config/key.pem /etc/xrdp/
RUN chown ubuntu:ubuntu -R /etc/xrdp


EXPOSE 3350
EXPOSE 3389

# remove clipit and deluge packages to get rid of more annoying UI stuff 
RUN apt-get remove -y \
    clipit \
    deluge
RUN /config/cleanup-cruft.sh

### Finish Build
ADD start-vnc.sh /usr/local/bin/start-vnc.sh
ENTRYPOINT ["tini", "--"]
CMD ["/usr/local/bin/start-vnc.sh"]

USER root
#USER ubuntu
#ENV HOME=/home/ubuntu
WORKDIR /home/ubuntu

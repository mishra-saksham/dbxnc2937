FROM ubuntu:14.04
MAINTAINER Philipz <philipzheng@gmail.com>

ENV DEBIAN_FRONTEND noninteractive
ENV HOME /root

# setup our Ubuntu sources (ADD breaks caching)
RUN echo "deb http://tw.archive.ubuntu.com/ubuntu/ trusty main\n\
deb http://tw.archive.ubuntu.com/ubuntu/ trusty multiverse\n\
deb http://tw.archive.ubuntu.com/ubuntu/ trusty universe\n\
deb http://tw.archive.ubuntu.com/ubuntu/ trusty restricted\n\
deb http://ppa.launchpad.net/chris-lea/node.js/ubuntu trusty main\n\
"> /etc/apt/sources.list

RUN apt-get update \
    && apt-get install -y --force-yes --no-install-recommends supervisor \
        sudo vim-tiny \
        net-tools \
        lxde x11vnc xvfb \
        gtk2-engines-murrine ttf-ubuntu-font-family \
        nodejs firefox

RUN apt-get install -y xrdp \ 
    && apt-get autoclean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/*

ADD noVNC /noVNC/

EXPOSE 6080
EXPOSE 5900
EXPOSE 3389

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
RUN useradd --create-home --shell /bin/bash --user-group --groups adm,sudo ubuntu
RUN echo "ubuntu:PASSWD" | chpasswd

# Define working directory.
VOLUME ["/home/ubuntu"]
CMD ["/usr/bin/supervisord","-n"]

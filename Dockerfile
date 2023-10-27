FROM fredblgr/ubuntu-novnc:20.04
EXPOSE 80
ENV RESOLUTION 1366*768 
CMD ["supervisord","-c","/etc/supervisor/supervisord.conf"]

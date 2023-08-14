
FROM ubuntu
RUN apt update && apt install rsyslog -y
COPY --chown=root:root log_rotation.sh /srv/log_rotation.sh
RUN echo '$ModLoad imudp \n\
$UDPServerRun 514 \n\
$ModLoad imtcp \n\
$InputTCPServerRun 514 \n\
$outchannel log_rotation,/var/log/log_rotation.log, 7500000,/srv/log_rotation.sh \n\
*.* :omfile:$log_rotation \n\
$template RemoteStore, "/var/log/rsyslog.log" \n\
:source, !isequal, "localhost" -?RemoteStore \n\
:source, isequal, "last" ~ ' > /etc/rsyslog.conf
ENTRYPOINT ["rsyslogd", "-n"]
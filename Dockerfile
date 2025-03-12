
FROM ubuntu
RUN apt update && apt install rsyslog -y
COPY --chmod=777 --chown=root:root log_rotation.sh /srv/log_rotation.sh
RUN echo '$ModLoad imudp \n\
$UDPServerRun 514 \n\
$ModLoad imtcp \n\
$InputTCPServerRun 514 \n\
input(type="imtcp" port="514") \n\
input(type="imudp" port="514") \n\
$AllowedSender TCP, 127.0.0.1, 192.168.0.0/24 \n\
$AllowedSender UDP, 127.0.0.1, 192.168.0.0/24 \n\
$outchannel log_rotation,/var/log/rsyslog.log, 7500000,/srv/log_rotation.sh \n\
*.* :omfile:$log_rotation \n\
$template RemoteStore, "/var/log/rsyslog.log" \n\
:source, !isequal, "localhost" -?RemoteStore \n\
:source, isequal, "last" ~ ' > /etc/rsyslog.conf
ENTRYPOINT ["rsyslogd", "-n"]
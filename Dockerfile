
FROM ubuntu
RUN apt update && apt upgrade -y && apt install rsyslog -y
RUN mkdir -p /mnt/rsyslog
COPY --chmod=777 --chown=root:root log_rotation.sh /srv/log_rotation.sh
RUN echo '$ModLoad imudp \n\
$ModLoad imtcp \n\
input(type="imtcp" port="514") \n\
input(type="imudp" port="514") \n\
$AllowedSender TCP, 127.0.0.1, 192.168.0.0/24 \n\
$AllowedSender UDP, 127.0.0.1, 192.168.0.0/24 \n\
$outchannel log_rotation,/mnt/rsyslog/rsyslog.log, 7500000,/srv/log_rotation.sh \n\
*.* :omfile:$log_rotation \n\
$template RemoteStore, "/mnt/rsyslog/rsyslog.log" ' > /etc/rsyslog.conf
#:source, !isequal, "localhost" -?RemoteStore 
#:source, isequal, "last" ~ ' > /etc/rsyslog.conf
ENTRYPOINT ["rsyslogd", "-n"]
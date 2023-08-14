#docker login -u ninjatec
docker build -t ninjatec/rsyslog .
docker push ninjatec/rsyslog:latest

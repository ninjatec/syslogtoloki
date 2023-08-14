NAME := rsyslog
VERSION := 1.0.2

build:
	DOCKER_BUILDKIT=1 docker build -t ninjatec/rsyslog:$(VERSION) .

publish:
	docker tag ninjatec/rsyslog:$(VERSION) ninjatec/ninjatec/rsyslog:$(VERSION)
	docker push ninjatec/rsyslog:$(VERSION)
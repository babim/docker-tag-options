#!/bin/bash
#  ____        _     _
# | __ )  __ _| |__ (_)_ __ ___
# |  _ \ / _` | '_ \| | '_ ` _ \
# | |_) | (_| | |_) | | | | | | |
# |____/ \__,_|_.__/|_|_| |_| |_|

echo 'Check root'
if [ "x$(id -u)" != 'x0' ]; then
    echo 'Error: this script can only be executed by root'
    exit 1
fi
echo 'Check OS'
if [[ -f /etc/alpine-release ]]; then
	# set environment
	DOWNLOAD_URL=${DOWNLOAD_URL:-"https://artifacts.elastic.co/downloads/elasticsearch"}
	ES_TARBAL="${DOWNLOAD_URL}/elasticsearch-${ES_VERSION}.tar.gz"
	# install depend
		apk add --no-cache ca-certificates gnupg openssl
	# Install Oracle Java
		apk add --no-cache openjdk8-jre tini su-exec libzmq bash libc6-compat
	# ensure elasticsearch user exists
		adduser -DH -s /sbin/nologin elasticsearch
	# install elasticsearch
	cd /tmp \
	  && echo "===> Install Elasticsearch..." \
	  && wget --no-check-certificate --progress=bar:force -O elasticsearch.tar.gz "$ES_TARBAL"; \
	  tar -xf elasticsearch.tar.gz \
	  && ls -lah \
	  && mv elasticsearch-$ES_VERSION /usr/share/elasticsearch \
	  && echo "===> Creating Elasticsearch Paths..." \
	  && for path in \
	  	/usr/share/elasticsearch/data \
	  	/usr/share/elasticsearch/logs \
	  	/usr/share/elasticsearch/config \
	  	/usr/share/elasticsearch/config/scripts \
		/usr/share/elasticsearch/tmp \
	  	/usr/share/elasticsearch/plugins \
	  ; do \
	  mkdir -p "$path"; \
	  chown -R elasticsearch:elasticsearch "$path"; \
	  done \
	  && rm -rf /tmp/*
	# download config files
		downloadentrypoint() {
			[[ ! -f /start.sh ]] || rm -f /start.sh
			cd /
		if [[ "$ES" = "6" ]]; then
			wget -O /start.sh --no-check-certificate https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20ElasticStack%20install/elasticsearch6_start.sh
		else
			wget -O /start.sh --no-check-certificate https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20ElasticStack%20install/elasticsearch_start.sh
		fi
			chmod 755 start.sh
		}
		prepareconfig() {
			[[ ! -f /usr/share/elasticsearch/config/elasticsearch.yml ]] || rm -f /usr/share/elasticsearch/config/elasticsearch.yml
			[[ ! -f /usr/share/elasticsearch/config/log4j2.properties ]] || rm -f /usr/share/elasticsearch/config/log4j2.properties
			[[ ! -f /usr/share/elasticsearch/config/logging.yml ]] || rm -f /usr/share/elasticsearch/config/logging.yml
			[[ -d /usr/share/elasticsearch/config ]] || mkdir -p /usr/share/elasticsearch/config
		}
		prepagelogrotage() {
			[[ ! -f /etc/logrotate.d/elasticsearch/logrotate ]] || rm -rf /etc/logrotate.d/elasticsearch/logrotate
			[[ -d /etc/logrotate.d/elasticsearch ]] || mkdir -p /etc/logrotate.d/elasticsearch
		}
	if [[ "$ES" = "1" ]] || [[ "$ES" = "2" ]]; then
		prepareconfig
		wget -O /usr/share/elasticsearch/config/elasticsearch.yml --no-check-certificate https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20ElasticStack%20install/elasticsearch_config/2/elasticsearch.yml
		wget -O /usr/share/elasticsearch/config/logging.yml --no-check-certificate https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20ElasticStack%20install/elasticsearch_config/2/logging.yml
	# download entrypoint
		downloadentrypoint
	else
		prepagelogrotage
		wget -O /etc/logrotate.d/elasticsearch/logrotate --no-check-certificate https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20ElasticStack%20install/elasticsearch_config/5/logrotate
		prepareconfig
		wget -O /usr/share/elasticsearch/config/elasticsearch.yml --no-check-certificate https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20ElasticStack%20install/elasticsearch_config/5/elasticsearch.yml
		wget -O /usr/share/elasticsearch/config/log4j2.properties --no-check-certificate https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20ElasticStack%20install/elasticsearch_config/5/log4j2.properties
	# download entrypoint
		downloadentrypoint
	fi
	if [[ "$XPACK" = "true" ]]; then
		[[ ! -f /usr/share/elasticsearch/config/x-pack/log4j2.properties ]] || rm -rf /usr/share/elasticsearch/config/x-pack/log4j2.properties
		[[ -d /usr/share/elasticsearch/config/x-pack ]] || mkdir -p /usr/share/elasticsearch/config/x-pack
		wget -O /usr/share/elasticsearch/config/x-pack/log4j2.properties --no-check-certificate https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20ElasticStack%20install/elasticsearch_config/x-pack/log4j2.properties
	fi
else
    echo "Not support your OS"
    exit
fi
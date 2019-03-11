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
	export JAVA_HOME=/usr/lib/jvm/java-1.8-openjdk/jre
	export PATH=$PATH:/usr/lib/jvm/java-1.8-openjdk/jre/bin:/usr/lib/jvm/java-1.8-openjdk/bin
	DOWNLOAD_URL=${DOWNLOAD_URL:-"https://artifacts.elastic.co/downloads/elasticsearch"}
	ES_TARBAL=${ES_TARBAL:-"${DOWNLOAD_URL}/elasticsearch-${ES_VERSION}.tar.gz"}
	export DOWN_URL="https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20ElasticStack%20install"
	# install depend
		apk add --no-cache ca-certificates gnupg openssl
	# Install Oracle Java
		apk add --no-cache openjdk8-jre tini su-exec libzmq bash libc6-compat
	# ensure elasticsearch user exists
		adduser -DH -s /sbin/nologin elasticsearch
	# install elasticsearch
	cd /tmp \
	  && echo "===> Install Elasticsearch..." \
	  && wget --no-check-certificate -O elasticsearch.tar.gz "$ES_TARBAL"; \
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
	# download entrypoint files
		downloadentrypoint() {
		FILETEMP=start.sh
			[[ ! -f /$FILETEMP ]] || rm -f /$FILETEMP
			cd /
		if [[ "$ES" = "6" ]]; then
			wget -O /$FILETEMP --no-check-certificate $DOWN_URL/elasticsearch6_$FILETEMP
		elif [[ "$ES" = "6" ]]; then
			wget -O /$FILETEMP --no-check-certificate $DOWN_URL/elasticsearch6_$FILETEMP
		elif [[ "$ES" = "1" ]]; then
			wget -O /$FILETEMP --no-check-certificate $DOWN_URL/elasticsearch1_$FILETEMP
		elif [[ "$ES" = "2" ]]; then
			wget -O /$FILETEMP --no-check-certificate $DOWN_URL/elasticsearch2_$FILETEMP
		else
			wget -O /$FILETEMP --no-check-certificate $DOWN_URL/elasticsearch5_$FILETEMP
		fi
			chmod 755 /$FILETEMP
		# Supervisor
		if [[ "$SUPERVISOR" = "true" ]] || [[ "$SUPERVISOR" = "yes" ]]; then
			wget --no-check-certificate -O - $DOWN_URL/supervisor_elasticsearch.sh | bash
		fi
		# prepare etc start
			wget --no-check-certificate -O - $DOWN_URL/prepare_final.sh | bash
		# docker health check
		FILETEMP=/usr/local/bin/docker-healthcheck
			[[ ! -f /$FILETEMP ]] || rm -f /$FILETEMP
			wget -O /$FILETEMP --no-check-certificate $DOWN_URL/elasticsearch_healthcheck/docker-healthcheck
			chmod 755 /$FILETEMP
		}
		prepareconfig() {
		FILETEMP=/usr/share/elasticsearch/config
			[[ -d $FILETEMP ]] || mkdir -p $FILETEMP
		if [[ "$ES" = "1" ]]; then
			FILETEMP=/usr/share/elasticsearch/config/elasticsearch.yml
				[[ -f $FILETEMP ]] && rm -f $FILETEMP
				wget -O $FILETEMP --no-check-certificate $DOWN_URL/elasticsearch_config/1/elasticsearch.yml
			FILETEMP=/usr/share/elasticsearch/config/logging.yml
				[[ -f $FILETEMP ]] && rm -f $FILETEMP
				wget -O $FILETEMP --no-check-certificate $DOWN_URL/elasticsearch_config/1/logging.yml
		elif [[ "$ES" = "2" ]]; then
			FILETEMP=/usr/share/elasticsearch/config/elasticsearch.yml
				[[ -f $FILETEMP ]] && rm -f $FILETEMP
				wget -O $FILETEMP --no-check-certificate $DOWN_URL/elasticsearch_config/2/elasticsearch.yml
			FILETEMP=/usr/share/elasticsearch/config/logging.yml
				[[ -f $FILETEMP ]] && rm -f $FILETEMP
				wget -O $FILETEMP --no-check-certificate $DOWN_URL/elasticsearch_config/2/logging.yml
		else
			FILETEMP=/usr/share/elasticsearch/config/elasticsearch.yml
				[[ -f $FILETEMP ]] && rm -f $FILETEMP
				wget -O $FILETEMP --no-check-certificate $DOWN_URL/elasticsearch_config/5/elasticsearch.yml
			FILETEMP=/usr/share/elasticsearch/config/log4j2.properties
				[[ -f $FILETEMP ]] && rm -f $FILETEMP
				wget -O $FILETEMP --no-check-certificate $DOWN_URL/elasticsearch_config/5/log4j2.properties
		fi
		}
		prepagelogrotage() {
			FILETEMP=/etc/logrotate.d/elasticsearch
			[[ -d $FILETEMP ]] || mkdir -p $FILETEMP
		if [[ "$ES" = "1" ]] || [[ "$ES" = "2" ]]; then
			echo not download
		else
			FILETEMP=/etc/logrotate.d/elasticsearch/logrotate
			[[ -f $FILETEMP ]] && rm -f $FILETEMP
			wget -O $FILETEMP --no-check-certificate $DOWN_URL/elasticsearch_config/5/logrotate
		fi
		}
	if [[ "$ES" = "1" ]] || [[ "$ES" = "2" ]]; then
		prepareconfig
	# download entrypoint
		downloadentrypoint
	else
		prepagelogrotage
		prepareconfig
	# download entrypoint
		downloadentrypoint
	fi
	if [[ "$XPACK" = "true" ]]; then
		FILETEMP=/usr/share/elasticsearch/config/x-pack
		[[ -d $FILETEMP ]] || mkdir -p $FILETEMP
		FILETEMP=/usr/share/elasticsearch/config/x-pack/log4j2.properties
		[[ -f $FILETEMP ]] && rm -f $FILETEMP
		wget -O $FILETEMP --no-check-certificate $DOWN_URL/elasticsearch_config/x-pack/log4j2.properties
	fi

	# remove packages
		wget --no-check-certificate -O - $DOWN_URL/elasticsearch_clean.sh | bash

else
    echo "Not support your OS"
    exit
fi
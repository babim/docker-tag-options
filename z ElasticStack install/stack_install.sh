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
	STACK_NEW=${STACK_NEW:-"true"}
	if [[ "$STACK_NEW" == "true" ]]; then
		ES_VERSION=$STACK
		LS_VERSION=$STACK
		KB_VERSION=$STACK
	fi
	ES_DOWNLOAD_URL=${DOWNLOAD_URL:-"https://artifacts.elastic.co/downloads/elasticsearch"}
	LS_DOWNLOAD_URL=${DOWNLOAD_URL:-"https://artifacts.elastic.co/downloads/logstash"}
	KB_DOWNLOAD_URL=${DOWNLOAD_URL:-"https://artifacts.elastic.co/downloads/kibana"}
	ES_TARBAL="${DOWNLOAD_URL}/elasticsearch-${ES_VERSION}.tar.gz"
	LS_TARBAL="${DOWNLOAD_URL}/logstash-${LS_VERSION}.tar.gz"
	KB_TARBAL="${DOWNLOAD_URL}/kibana-${KB_VERSION}.tar.gz"
	LS_SETTINGS_DIR=${LS_SETTINGS_DIR:-"/etc/logstash"}
	DOWN_URL="--no-check-certificate https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20ElasticStack%20install"

	# install depend
		apk add --no-cache libzmq bash nodejs supervisor nginx apache2-utils openssl libc6-compat
	# Install Oracle Java
		apk add --no-cache openjdk8-jre tini su-exec
	# make libzmq.so
		mkdir -p /usr/local/lib \
		&& ln -s /usr/lib/*/libzmq.so.3 /usr/local/lib/libzmq.so
	# ensure elstack user exists
		adduser -DH -s /sbin/nologin elstack
	# install elstack
		set -x \
		  && cd /tmp \
		  && echo "Download Elastic Stack ======================================================" \
		  && echo "Download Elasticsearch..." \
		  && wget --no-check-certificate --progress=bar:force -O elasticsearch-$ES_VERSION.tar.gz "$ES_TARBAL" \
		  && tar -xzf elasticsearch-$ES_VERSION.tar.gz \
		  && mv elasticsearch-$ES_VERSION /usr/share/elasticsearch \
		  && echo "Download Logstash..." \
		  && wget --no-check-certificate --progress=bar:force -O logstash-$LS_VERSION.tar.gz "$LS_TARBAL" \
		  && tar -xzf logstash-$LS_VERSION.tar.gz \
		  && mv logstash-$LS_VERSION /usr/share/logstash \
		  && echo "Download Kibana..." \
		  && wget --no-check-certificate --progress=bar:force -O kibana-$KB_VERSION.tar.gz "$KB_TARBAL" \
		  && tar -xzf kibana-$KB_VERSION.tar.gz \
		  && mv kibana-$KB_VERSION-linux-x86_64 /usr/share/kibana \
		  && echo "Configure [Elasticsearch] ===================================================" \
		  && for path in \
		  	/usr/share/elasticsearch/data \
		  	/usr/share/elasticsearch/logs \
		  	/usr/share/elasticsearch/config \
		  	/usr/share/elasticsearch/config/scripts \
		  	/usr/share/elasticsearch/plugins \
			/usr/share/elasticsearch/tmp \
		  ; do \
		  mkdir -p "$path"; \
		  done \
		  && echo "Configure [Logstash] ========================================================" \
		  && if [ -f "$LS_SETTINGS_DIR/logstash.yml" ]; then \
		  		sed -ri 's!^(path.log|path.config):!#&!g' "$LS_SETTINGS_DIR/logstash.yml"; \
		  	fi \
		  && echo "Configure [Kibana] =========================================================="
		  # the default "server.host" is "localhost" in 5+
		  sed -ri "s!^(\#\s*)?(server\.host:).*!\2 '0.0.0.0'!" /usr/share/kibana/config/kibana.yml \
		  && grep -q "^server\.host: '0.0.0.0'\$" /usr/share/kibana/config/kibana.yml
		  # usr alpine nodejs and not bundled version
		  bundled='NODE="${DIR}/node/bin/node"' \
		  && apline_node='NODE="/usr/bin/node"' \
		  && sed -i "s|$bundled|$apline_node|g" /usr/share/kibana/bin/kibana-plugin \
		  && sed -i "s|$bundled|$apline_node|g" /usr/share/kibana/bin/kibana \
		  && rm -rf /usr/share/kibana/node \
		  && echo "Make Ngins SSL directory..." \
		  && mkdir -p /etc/nginx/ssl \
		  && chown -R elstack:elstack /usr/share/elasticsearch \
		  && chown -R elstack:elstack /usr/share/logstash \
		  && chown -R elstack:elstack /usr/share/kibana \
		  && echo "Clean Up..." \
		  && rm -rf /tmp/*

	# download config files
		downloadentrypoint() {
			FILETEMP=/elastic-entrypoint.sh
			[[ ! -f $FILETEMP ]] || rm -f $FILETEMP
			wget -O $FILETEMP $DOWN_URL/stack_config/entrypoints$FILETEMP
			FILETEMP=/logstash-entrypoint.shsh
			[[ ! -f $FILETEMP ]] || rm -f $FILETEMP
			wget -O $FILETEMP $DOWN_URL/stack_config/entrypoints$FILETEMP
			FILETEMP=/kibana-entrypoint.sh
			[[ ! -f $FILETEMP ]] || rm -f $FILETEMP
			wget -O $FILETEMP $DOWN_URL/stack_config/entrypoints$FILETEMP
			FILETEMP=/nginx-entrypoint.sh
			[[ ! -f $FILETEMP ]] || rm -f $FILETEMP
			wget -O $FILETEMP $DOWN_URL/stack_config/entrypoints$FILETEMP
			chmod 755 /*.sh
		}
		prepareconfig() {
		# elasticsearch
			FILETEMP=/usr/share/elasticsearch/config/elasticsearch.yml
			[[ ! -f $FILETEMP ]] || rm -f $FILETEMP
			wget -O $FILETEMP $DOWN_URL/stack_config/config/elastic/elasticsearch.yml
			FILETEMP=/usr/share/elasticsearch/config/log4j2.properties
			[[ ! -f $FILETEMP ]] || rm -f $FILETEMP
			wget -O $FILETEMP $DOWN_URL/stack_config/config/elastic/log4j2.properties
			FILETEMP=/etc/logrotate.d/elasticsearch/logrotate
			[[ ! -f $FILETEMP ]] || rm -f $FILETEMP
			wget -O $FILETEMP $DOWN_URL/stack_config/config/elastic/logrotate
			FILETEMP=/usr/share/elasticsearch/config
			[[ -d $FILETEMP ]] || mkdir -p $FILETEMP
			FILETEMP=/etc/logrotate.d/elasticsearch
			[[ -d $FILETEMP ]] || mkdir -p $FILETEMP
		# logstash
			FILETEMP=/etc/logstash/conf.d/02-beats-input.conf
			[[ ! -f $FILETEMP ]] || rm -f $FILETEMP
			wget -O $FILETEMP $DOWN_URL/stack_config/config/logstash/conf.d/02-beats-input.conf
			FILETEMP=/etc/logstash/conf.d/10-syslog-filter.conf
			[[ ! -f $FILETEMP ]] || rm -f $FILETEMP
			wget -O $FILETEMP $DOWN_URL/stack_config/config/logstash/conf.d/10-syslog-filter.conf
			FILETEMP=/etc/logstash/conf.d/11-nginx-filter.conf
			[[ ! -f $FILETEMP ]] || rm -f $FILETEMP
			wget -O $FILETEMP $DOWN_URL/stack_config/config/logstash/conf.d/11-nginx-filter.conf
			FILETEMP=/etc/logstash/conf.d/30-elasticsearch-output.conf
			[[ ! -f $FILETEMP ]] || rm -f $FILETEMP
			wget -O $FILETEMP $DOWN_URL/stack_config/config/logstash/conf.d/30-elasticsearch-output.conf
			FILETEMP=/opt/logstash/patterns/nginx
			[[ ! -f $FILETEMP ]] || rm -f $FILETEMP
			wget -O $FILETEMP $DOWN_URL/stack_config/config/logstash/patterns/nginx
			FILETEMP=/etc/logstash/logstash.yml
			[[ ! -f $FILETEMP ]] || rm -f $FILETEMP
			wget -O $FILETEMP $DOWN_URL/stack_config/config/logstash/logstash.yml
			FILETEMP=/etc/logstash/conf.d
			[[ -d $FILETEMP ]] || mkdir -p $FILETEMP
			FILETEMP=/opt/logstash/patterns
			[[ -d $FILETEMP ]] || mkdir -p $FILETEMP
			FILETEMP=/etc/logstash
			[[ -d $FILETEMP ]] || mkdir -p $FILETEMP
		# nginx
			FILETEMP=/etc/nginx/nginx.conf
			[[ ! -f $FILETEMP ]] || rm -f $FILETEMP
			wget -O $FILETEMP $DOWN_URL/stack_config/config/nginx/nginx.conf
			FILETEMP=/etc/nginx/conf.d/kibana.conf
			[[ ! -f $FILETEMP ]] || rm -f $FILETEMP
			wget -O $FILETEMP $DOWN_URL/stack_config/config/nginx/kibana.conf
			FILETEMP=/etc/nginx/conf.d/ssl.kibana.conf
			[[ ! -f $FILETEMP ]] || rm -f $FILETEMP
			wget -O $FILETEMP $DOWN_URL/stack_config/config/nginx/ssl.kibana.conf
			FILETEMP=/etc/nginx/conf.d
			[[ -d $FILETEMP ]] || mkdir -p $FILETEMP
		# supervisor
			FILETEMP=/etc/supervisor/supervisord.conf
			[[ ! -f $FILETEMP ]] || rm -f $FILETEMP
			wget -O $FILETEMP $DOWN_URL/stack_config/config/supervisord/supervisord.conf
			FILETEMP=/etc/supervisor
			[[ -d $FILETEMP ]] || mkdir -p $FILETEMP
		}
		downloadentrypoint
		prepareconfig
	if [[ "$STACK_NEW" = "false" ]]; then
			FILETEMP=/etc/supervisor/supervisord.conf
			[[ ! -f $FILETEMP ]] || rm -f $FILETEMP
			wget -O $FILETEMP $DOWN_URL/stack_config/3/supervisord/supervisord.conf
	fi
else
    echo "Not support your OS"
    exit
fi
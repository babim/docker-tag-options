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
	LS_URL=${LS_URL:-"https://artifacts.elastic.co/downloads/logstash"}
	LS_TARBAL=${LS_TARBAL:-"${LS_URL}/logstash-${LS_VERSION}.tar.gz"}
	LS_SETTINGS_DIR=${LS_SETTINGS_DIR:-"/usr/share/logstash/config"}
	DOWN_URL="--no-check-certificate https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20ElasticStack%20install"
	# install depend
		apk add --no-cache wget ca-certificates gnupg openssl supervisor
	# Install Oracle Java
		apk add --no-cache openjdk8-jre tini su-exec libzmq bash libc6-compat
	# make libzmq.so
		mkdir -p /usr/local/lib \
		&& ln -s /usr/lib/*/libzmq.so.3 /usr/local/lib/libzmq.so
	# ensure logstash user exists
		adduser -DH -s /sbin/nologin logstash
	# install logstash
		set -ex \
		&& cd /tmp \
		&& wget --no-check-certificate --progress=bar:force -O logstash.tar.gz "$LS_TARBAL" \
		&& tar -xzf logstash.tar.gz \
		&& mv logstash-$LS_VERSION /usr/share/logstash \
		&& rm -rf /tmp/*
	# config setting
		set -ex; \
		if [ -f "$LS_SETTINGS_DIR/log4j2.properties" ]; then \
		cp "$LS_SETTINGS_DIR/log4j2.properties" "$LS_SETTINGS_DIR/log4j2.properties.dist"; \
		truncate -s 0 "$LS_SETTINGS_DIR/log4j2.properties"; \
		fi
	# download entrypoint files
		downloadentrypoint() {
			FILETEMP=/start.sh
			[[ ! -f $FILETEMP ]] || rm -f $FILETEMP
			wget -O $FILETEMP --no-check-certificate $DOWN_URL/logstash_start.sh && \
			chmod 755 $FILETEMP
		# Supervisor config
			[[ -d /var/log/supervisor ]] || mkdir -p /var/log/supervisor/
			[[ -d /etc/supervisor/conf.d ]] || mkdir -p /etc/supervisor/conf.d/
		# download sypervisord config
		FILETEMP=/etc/supervisor/supervisord.conf
			[[ ! -f $FILETEMP ]] || rm -f $FILETEMP
			wget -O $FILETEMP $DOWN_URL/supervisor/supervisord.conf
		FILETEMP=/etc/supervisord.conf
			[[ ! -f $FILETEMP ]] || ln -sf /etc/supervisor/supervisord.conf $FILETEMP
		FILETEMP=/etc/supervisor/conf.d/logstash.conf
			[[ ! -f $FILETEMP ]] || rm -f $FILETEMP
			wget -O $FILETEMP $DOWN_URL/supervisor/conf.d/logstash.conf
		# prepare etc start
			[[ ! -d /etc-start ]] || rm -rf /etc-start
			[[ ! -d /etc/supervisor ]] || mkdir -p /etc-start/supervisor
			[[ ! -d /etc/supervisor ]] || cp -R /etc/supervisor/* /etc-start/supervisor
		}
	if [[ "$LOGSTASH" = "6" ]]; then
		FILETEMP=/usr/share/logstash/config
		[[ -d $FILETEMP ]] || mkdir -p $FILETEMP
		FILETEMP=/usr/share/logstash/pipeline
		[[ -d $FILETEMP ]] || mkdir -p $FILETEMP
		FILETEMP=/usr/share/logstash/config/log4j2.properties
		[[ ! -f $FILETEMP ]] || rm -f $FILETEMP
		wget -O $FILETEMP $DOWN_URL/logstash_config/6/logstash/log4j2.properties
		FILETEMP=/usr/share/logstash/config/logstash.yml
		[[ ! -f $FILETEMP ]] || rm -f $FILETEMP
		wget -O $FILETEMP $DOWN_URL/logstash_config/6/logstash/logstash.yml
		FILETEMP=/usr/share/logstash/pipeline/logstash.conf
		[[ ! -f $FILETEMP ]] || rm -f $FILETEMP
		wget -O $FILETEMP $DOWN_URL/logstash_config/6/pipeline/default.conf
		downloadentrypoint
	else
		downloadentrypoint
	fi
	if [[ "$XPACK" = "true" ]]; then
		FILETEMP=/usr/share/logstash/config/logstash.yml
		[[ ! -f $FILETEMP ]] || rm -f $FILETEMP
		wget -O $FILETEMP $DOWN_URL/logstash_config/xpack/logstash/logstash.yml
	fi
else
    echo "Not support your OS"
    exit
fi
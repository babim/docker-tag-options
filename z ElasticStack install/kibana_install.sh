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
	DOWNLOAD_URL=${DOWNLOAD_URL:-"https://artifacts.elastic.co/downloads/kibana"}
	BIT=${BIT:-"x86_64"}
	TARBAL="${DOWNLOAD_URL}/kibana-${KIBANA_VERSION}-linux-${BIT}.tar.gz"
	# install depend
		apk add --no-cache nodejs su-exec
		apk add --no-cache wget curl ca-certificates gnupg openssl
	# ensure kibana user exists
		adduser -DH -s /sbin/nologin kibana
	# install kibana
		set -ex && cd /tmp \
		&& echo "===> Install Kibana..." \
		&& wget --no-check-certificate --progress=bar:force -O kibana.tar.gz "$TARBAL"; \
		tar -xf kibana.tar.gz \
		&& ls -lah \
		&& mv kibana-$KIBANA_VERSION-linux-${BIT} /usr/share/kibana
	# Config after install
	if [[ "$KIBANA" = "4" ]]; then
		rm /usr/share/kibana/node/bin/node && \
		rm /usr/share/kibana/node/bin/npm && \
		ln -s /usr/bin/node /usr/share/kibana/node/bin/node && \
		ln -s /usr/bin/npm /usr/share/kibana/node/bin/npm && \
		rm -rf /var/cache/apk/* /kibana-${KIBANA_VERSION}-linux-${BIT}.tar.gz
	else
  	# the default "server.host" is "localhost" in 5+
		sed -ri "s!^(\#\s*)?(server\.host:).*!\2 '0.0.0.0'!" /usr/share/kibana/config/kibana.yml \
		&& grep -q "^server\.host: '0.0.0.0'\$" /usr/share/kibana/config/kibana.yml 
  	# ensure the default configuration is useful when using --link
		sed -ri "s!^(\#\s*)?(elasticsearch\.url:).*!\2 'http://elasticsearch:9200'!" /usr/share/kibana/config/kibana.yml \
		&& grep -q "^elasticsearch\.url: 'http://elasticsearch:9200'\$" /usr/share/kibana/config/kibana.yml
 	 # usr alpine nodejs and not bundled version
		bundled='NODE="${DIR}/node/bin/node"' \
		&& apline_node='NODE="/usr/bin/node"' \
		&& sed -i "s|$bundled|$apline_node|g" /usr/share/kibana/bin/kibana-plugin \
		&& sed -i "s|$bundled|$apline_node|g" /usr/share/kibana/bin/kibana \
		&& rm -rf /usr/share/kibana/node \
		&& chown -R kibana:kibana /usr/share/kibana \
		&& rm -rf /tmp/*
	fi
	# download config files
		downloadentrypoint() {
			[[ ! -f /start.sh ]] || rm -f /start.sh
		if [[ "$KIBANA" = "6" ]]; then
			wget -O /start.sh --no-check-certificate https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20ElasticStack%20install/kibana6_start.sh
		else
			wget -O /start.sh --no-check-certificate https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20ElasticStack%20install/kibana_start.sh
		fi
			chmod 755 /start.sh
		}
	if [[ "$KIBANA" = "4" ]]; then
		wget -O /usr/share/kibana/config/kibana.yml --no-check-certificate https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20ElasticStack%20install/kibana_config/4/kibana.yml
		downloadentrypoint
	else
		downloadentrypoint
	fi
else
    echo "Not support your OS"
    exit
fi
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
	TARBAL=${TARBAL:-"${DOWNLOAD_URL}/kibana-${KB_VERSION}-linux-${BIT}.tar.gz"}
	export DOWN_URL="https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20ElasticStack%20install"
	# install depend
		apk add --no-cache nodejs su-exec tini
		apk add --no-cache ca-certificates gnupg openssl
	# ensure kibana user exists
		adduser -DH -s /sbin/nologin kibana
	# install kibana
		cd /tmp
		echo "===> Install Kibana..."
		wget --no-check-certificate -O kibana.tar.gz "$TARBAL"
		tar -xf kibana.tar.gz
		ls -lah
		[[ -d "kibana-$KB_VERSION-linux-${BIT}" ]]	&& mv kibana-$KB_VERSION-linux-${BIT} /usr/share/kibana
	# Config after install
	if [[ "$KIBANA" = "4" ]]; then
		[[ -f "/usr/share/kibana/node/bin/node" ]]	&& rm /usr/share/kibana/node/bin/node
		[[ -f "/usr/share/kibana/node/bin/npm" ]]	&& rm /usr/share/kibana/node/bin/npm
		ln -s /usr/bin/node /usr/share/kibana/node/bin/node
		ln -s /usr/bin/npm /usr/share/kibana/node/bin/npm
		sed -ri "s!^(\#\s*)?(server\.host:).*!\2 '0.0.0.0'!" /usr/share/kibana/config/kibana.yml
		grep -q "^server\.host: '0.0.0.0'\$" /usr/share/kibana/config/kibana.yml 
  	# ensure the default configuration is useful when using --link
		sed -ri "s!^(\#\s*)?(elasticsearch\.url:).*!\2 'http://elasticsearch:9200'!" /usr/share/kibana/config/kibana.yml
		grep -q "^elasticsearch\.url: 'http://elasticsearch:9200'\$" /usr/share/kibana/config/kibana.yml
	elif [ "${KB_VERSION}" == "6.6.0" ] || [ "${KB_VERSION}" == "6.6.1" ] || [ "${KB_VERSION}" == "6.6.2" ] || [ "${KB_VERSION}" == "6.6.3" ] || [ "${KB_VERSION}" == "6.6.4" ]; then
		echo "no need sed value"
	else
		sed -ri "s!^(\#\s*)?(server\.host:).*!\2 '0.0.0.0'!" /usr/share/kibana/config/kibana.yml
		grep -q "^server\.host: '0.0.0.0'\$" /usr/share/kibana/config/kibana.yml 
  	# ensure the default configuration is useful when using --link
		sed -ri "s!^(\#\s*)?(elasticsearch\.url:).*!\2 'http://elasticsearch:9200'!" /usr/share/kibana/config/kibana.yml
		grep -q "^elasticsearch\.url: 'http://elasticsearch:9200'\$" /usr/share/kibana/config/kibana.yml
	fi
 	 # usr alpine nodejs and not bundled version
		bundled='NODE="${DIR}/node/bin/node"'
		apline_node='NODE="/usr/bin/node"'
		sed -i "s|$bundled|$apline_node|g" /usr/share/kibana/bin/kibana-plugin
		sed -i "s|$bundled|$apline_node|g" /usr/share/kibana/bin/kibana
		rm -rf /usr/share/kibana/node
		chown -R kibana:kibana /usr/share/kibana
	# clean
		rm -rf /var/cache/apk/*
		rm -rf /tmp/*
		[[ -f "/kibana-${KB_VERSION}-linux-${BIT}.tar.gz" ]]	&& /kibana-${KB_VERSION}-linux-${BIT}.tar.gz
		[[ -f "kibana-${KB_VERSION}-linux-${BIT}.tar.gz" ]]	&& /kibana-${KB_VERSION}-linux-${BIT}.tar.gz
	# download entrypoint files
		downloadentrypoint() {
			[[ ! -f /start.sh ]] || rm -f /start.sh
		if [[ "$KIBANA" = "6" ]]; then
			wget -O /start.sh --no-check-certificate $DOWN_URL/kibana6_start.sh
		else
			wget -O /start.sh --no-check-certificate $DOWN_URL/kibana_start.sh
		fi
			chmod 755 /start.sh
		# Supervisor
		if [[ "$SUPERVISOR" = "true" ]] || [[ "$SUPERVISOR" = "yes" ]]; then
			wget --no-check-certificate -O - $DOWN_URL/supervisor_kibana.sh | bash
		fi
		# prepare etc start
			wget --no-check-certificate -O - $DOWN_URL/prepare_final.sh | bash
		}
	if [[ "$KIBANA" = "4" ]]; then
		wget -O /usr/share/kibana/config/kibana.yml --no-check-certificate $DOWN_URL/kibana_config/4/kibana.yml
		downloadentrypoint
	else
		downloadentrypoint
	fi

	# remove packages
		wget --no-check-certificate -O - $DOWN_URL/kibana_clean.sh | bash

else
    echo "Not support your OS"
    exit
fi
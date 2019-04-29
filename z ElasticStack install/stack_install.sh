#!/bin/bash
#  ____        _     _
# | __ )  __ _| |__ (_)_ __ ___
# |  _ \ / _` | '_ \| | '_ ` _ \
# | |_) | (_| | |_) | | | | | | |
# |____/ \__,_|_.__/|_|_| |_| |_|

# Stop script on NZEC
set -e
# Stop script if unbound variable found (use ${var:-} if intentional)
# set -u
# By default cmd1 | cmd2 returns exit code of cmd2 regardless of cmd1 success
# This is causing it to fail
set -o pipefail

#####################################
    ####### Set download tool #######
    ####### and load library ########
# check has package
function    machine_has() {
        hash "$1" > /dev/null 2>&1
        return $?; }
# Check and set download tool
echo "Check and set download tool..."
if machine_has "curl"; then
    source <(curl -s https://raw.githubusercontent.com/babim/docker-tag-options/master/lib/libbash)
elif machine_has "wget"; then
    source <(wget -qO- https://raw.githubusercontent.com/babim/docker-tag-options/master/lib/libbash)
else
    echo "without download tool"
    sleep 3
    exit 1
fi
download_option
#####################################

# need root to run
	require_root

# set environment
setenvironment() {
	export UNINSTALL="ca-certificates gnupg openssl"
	export OPENJDKV=${OPENJDKV:-8}
	env_openjdk_jre
	STACK_NEW=${STACK_NEW:-"true"}
	if check_value_true "$STACK_NEW"; then
		ES_VERSION=$STACK
		LS_VERSION=$STACK
		KB_VERSION=$STACK
	fi
	BIT=${BIT:-"$(uname -m)"}
	ES_DOWNLOAD_URL=${ES_DOWNLOAD_URL:-"https://artifacts.elastic.co/downloads/elasticsearch"}
	LS_DOWNLOAD_URL=${LS_DOWNLOAD_URL:-"https://artifacts.elastic.co/downloads/logstash"}
	KB_DOWNLOAD_URL=${KB_DOWNLOAD_URL:-"https://artifacts.elastic.co/downloads/kibana"}
	ES_TARBAL=${ES_TARBAL:-"${ES_DOWNLOAD_URL}/elasticsearch-${ES_VERSION}.tar.gz"}
	LS_TARBAL=${LS_TARBAL:-"${LS_DOWNLOAD_URL}/logstash-${LS_VERSION}.tar.gz"}
	KB_TARBAL=${KB_TARBAL:-"${KB_DOWNLOAD_URL}/kibana-${KB_VERSION}-linux-${BIT}.tar.gz"}
	LS_SETTINGS_DIR=${LS_SETTINGS_DIR:-"/etc/logstash"}
	export DOWN_URL="https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20ElasticStack%20install"
	# set ID docker run
	export auser=${auser:-elstack}
	export aguser=${aguser:-$auser}
}
# download config files
downloadentrypoint() {
	FILETEMP=/elastic-entrypoint.sh
		$download_save $FILETEMP $DOWN_URL/stack_config/entrypoints$FILETEMP
	FILETEMP=/logstash-entrypoint.sh
		$download_save $FILETEMP $DOWN_URL/stack_config/entrypoints$FILETEMP
	FILETEMP=/kibana-entrypoint.sh
		$download_save $FILETEMP $DOWN_URL/stack_config/entrypoints$FILETEMP
	FILETEMP=/nginx-entrypoint.sh
		$download_save $FILETEMP $DOWN_URL/stack_config/entrypoints$FILETEMP
	chmod 755 /*.sh
}
# Supervisor
supervisorconfig() {
	run_url $DOWN_URL/supervisor_stack.sh
}
# prepare etc start
preparefinal() {
	run_url $DOWN_URL/prepare_final.sh
}
prepareconfig() {
# elasticsearch
	create_folder /usr/share/elasticsearch/config
	create_folder /etc/logrotate.d/elasticsearch
	FILETEMP=/usr/share/elasticsearch/config/elasticsearch.yml
		$download_save $FILETEMP $DOWN_URL/stack_config/config/elastic/elasticsearch.yml
	FILETEMP=/usr/share/elasticsearch/config/log4j2.properties
		$download_save $FILETEMP $DOWN_URL/stack_config/config/elastic/log4j2.properties
	FILETEMP=/etc/logrotate.d/elasticsearch/logrotate
		$download_save $FILETEMP $DOWN_URL/stack_config/config/elastic/logrotate
# logstash
	create_folder /etc/logstash/conf.d
	create_folder /opt/logstash/patterns
	create_folder /etc/logstash
	FILETEMP=/etc/logstash/conf.d/02-beats-input.conf
		$download_save $FILETEMP $DOWN_URL/stack_config/config/logstash/conf.d/02-beats-input.conf
	FILETEMP=/etc/logstash/conf.d/10-syslog-filter.conf
		$download_save $FILETEMP $DOWN_URL/stack_config/config/logstash/conf.d/10-syslog-filter.conf
	FILETEMP=/etc/logstash/conf.d/11-nginx-filter.conf
		$download_save $FILETEMP $DOWN_URL/stack_config/config/logstash/conf.d/11-nginx-filter.conf
	FILETEMP=/etc/logstash/conf.d/30-elasticsearch-output.conf
		$download_save $FILETEMP $DOWN_URL/stack_config/config/logstash/conf.d/30-elasticsearch-output.conf
	FILETEMP=/opt/logstash/patterns/nginx
		$download_save $FILETEMP $DOWN_URL/stack_config/config/logstash/patterns/nginx
	FILETEMP=/etc/logstash/logstash.yml
		$download_save $FILETEMP $DOWN_URL/stack_config/config/logstash/logstash.yml
# nginx
	create_folder /etc/nginx/conf.d
	FILETEMP=/etc/nginx/nginx.conf
		$download_save $FILETEMP $DOWN_URL/stack_config/config/nginx/nginx.conf
	FILETEMP=/etc/nginx/conf.d/kibana.conf
		$download_save $FILETEMP $DOWN_URL/stack_config/config/nginx/kibana.conf
	FILETEMP=/etc/nginx/conf.d/ssl.kibana.conf
		$download_save $FILETEMP $DOWN_URL/stack_config/config/nginx/ssl.kibana.conf
}

# install by OS
echo 'Check OS'
if [[ -f /etc/alpine-release ]]; then
	# set environment
		setenvironment
	# install depend
		install_java_jre
			echo "Install depend packages..."
		install_package nodejs nginx apache2-utils openssl ca-certificates gnupg openssl tini su-exec libzmq libc6-compat
	# make libzmq.so
		create_folder /usr/local/lib \
		&& ln -sf /usr/lib/*/libzmq.so.3 /usr/local/lib/libzmq.so
	# ensure elstack user exists
		adduser -DH -s /sbin/nologin $auser
	# install elstack
		set -x
		  cd /tmp
		  say "Download Elastic Stack ======================================================"
		  say "Download Elasticsearch..."
		  $download_save elasticsearch-$ES_VERSION.tar.gz "$ES_TARBAL"
		  tar -xzf elasticsearch-$ES_VERSION.tar.gz
		FILETEMP=elasticsearch-$ES_VERSION
		  check_folder $FILETEMP	&& mv $FILETEMP /usr/share/elasticsearch	|| say "${FILETEMP} does not exist"
		FILETEMP=elasticsearch-oss-$ES_VERSION
		  check_folder $FILETEMP	&& mv $FILETEMP /usr/share/elasticsearch 	|| say "${FILETEMP} does not exist"
		  say "Download Logstash..."
		  $download_save logstash-$LS_VERSION.tar.gz "$LS_TARBAL"
		  tar -xzf logstash-$LS_VERSION.tar.gz
		FILETEMP=logstash-$LS_VERSION
		  check_folder $FILETEMP	&& mv $FILETEMP /usr/share/logstash		|| say "${FILETEMP} does not exist"
		FILETEMP=logstash-oss-$LS_VERSION
		  check_folder $FILETEMP	&& mv $FILETEMP /usr/share/logstash 		|| say "${FILETEMP} does not exist"
		  say "Download Kibana..."
		  $download_save kibana-$KB_VERSION.tar.gz "$KB_TARBAL"
		  tar -xzf kibana-$KB_VERSION.tar.gz
		FILETEMP=kibana-$KB_VERSION-linux-x86_64
		  check_folder $FILETEMP	&& mv $FILETEMP /usr/share/kibana		|| say "${FILETEMP} does not exist"
		FILETEMP=kibana-oss-$KB_VERSION-linux-x86_64
		  check_folder $FILETEMP	&& mv $FILETEMP /usr/share/kibana 		|| say "${FILETEMP} does not exist"
		  say "Configure [Elasticsearch] ==================================================="
		  for path in \
		  	/usr/share/elasticsearch/data \
		  	/usr/share/elasticsearch/logs \
		  	/usr/share/elasticsearch/config \
		  	/usr/share/elasticsearch/config/scripts \
		  	/usr/share/elasticsearch/plugins \
			/usr/share/elasticsearch/tmp \
		  ; do \
		  create_folder "$path"; \
		  done
		  say "Configure [Logstash] ========================================================"
		  if check_file "$LS_SETTINGS_DIR/logstash.yml"; then
		  	sed -ri 's!^(path.log|path.config):!#&!g' "$LS_SETTINGS_DIR/logstash.yml"
		  fi
		  say "Configure [Kibana] =========================================================="
		  # the default "server.host" is "localhost" in 5+
		  sed -ri "s!^(\#\s*)?(server\.host:).*!\2 '0.0.0.0'!" /usr/share/kibana/config/kibana.yml
		  grep -q "^server\.host: '0.0.0.0'\$" /usr/share/kibana/config/kibana.yml
		  # usr alpine nodejs and not bundled version
		  bundled='NODE="${DIR}/node/bin/node"'
		  apline_node='NODE="/usr/bin/node"'
	FILETEMP=/usr/share/kibana/bin/kibana-plugin
		check_folder ${FILETEMP} && sed -i "s|$bundled|$apline_node|g" ${FILETEMP} || say "${FILETEMP} does not exist"
	FILETEMP=/usr/share/kibana/bin/kibana
		check_folder ${FILETEMP} && sed -i "s|$bundled|$apline_node|g" ${FILETEMP} || say "${FILETEMP} does not exist"
		  remove_folder /usr/share/kibana/node
		  say "Make Ngins SSL directory..."
		  create_folder /etc/nginx/ssl
		  set_filefolder_owner $auser:$aguser /usr/share/elasticsearch
		  set_filefolder_owner $auser:$aguser /usr/share/logstash
		  set_filefolder_owner $auser:$aguser /usr/share/kibana
		  say "Clean Up..."
		  remove_filefolder /tmp/*

		prepareconfig
		downloadentrypoint
		supervisorconfig
		preparefinal

	# clean
		remove_download_tool
		clean_package
		clean_os
	
# OS - other
else
    say_err "Not support your OS"
    exit 1
fi
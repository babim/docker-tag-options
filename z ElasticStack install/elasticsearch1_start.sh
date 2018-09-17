#!/bin/bash
#  ____        _     _
# | __ )  __ _| |__ (_)_ __ ___
# |  _ \ / _` | '_ \| | '_ ` _ \
# | |_) | (_| | |_) | | | | | | |
# |____/ \__,_|_.__/|_|_| |_| |_|

set -e

# copy config supervisor
if [ -d "/etc/supervisor" ] && [ -d "/etc-start/supervisor" ];then
if [ ! -f "/etc/supervisor/supervisord.conf" ]; then cp -R -f /etc-start/supervisor/* /etc/supervisor; fi
fi

# option with entrypoint
if [ -f "/option.sh" ]; then /option.sh; fi

es_opts=''

# Add elasticsearch as command if needed
if [ "${1:0:1}" = '-' ]; then
	set -- elasticsearch "$@" ${es_opts}
fi

# Drop root privileges if we are running elasticsearch
# allow the container to be started with `--user`
if [ "$1" = 'elasticsearch' -a "$(id -u)" = '0' ]; then
	# Change the ownership of /usr/share/elasticsearch/data to elasticsearch
	chown -R elasticsearch:elasticsearch /usr/share/elasticsearch/data

	set -- su-exec elasticsearch /sbin/tini -s -- "$@" ${es_opts}
	#exec su-exec elasticsearch "$BASH_SOURCE" "$@"
fi

if [ "$1" = 'kopf' -a "$(id -u)" = '0' ]; then
	# Install kopf plugin
	plugin install lmenezes/elasticsearch-kopf/v2.1.1

	# Change the ownership of /usr/share/elasticsearch/data to elasticsearch
	chown -R elasticsearch:elasticsearch /usr/share/elasticsearch/data

	set -- su-exec elasticsearch tini -- elasticsearch
	#exec su-exec elasticsearch "$BASH_SOURCE" "$@"
fi

if [ "$1" = 'master' -a "$(id -u)" = '0' ]; then
	# Change node into a master node
	echo "node.master: true" >> /usr/share/elasticsearch/config/elasticsearch.yml
	echo "node.client: false" >> /usr/share/elasticsearch/config/elasticsearch.yml
	echo "node.data: false" >> /usr/share/elasticsearch/config/elasticsearch.yml

	# Change the ownership of /usr/share/elasticsearch/data to elasticsearch
	chown -R elasticsearch:elasticsearch /usr/share/elasticsearch/data

	set -- su-exec elasticsearch /sbin/tini -- elasticsearch ${es_opts}
	#exec su-exec elasticsearch "$BASH_SOURCE" "$@"
fi

if [ "$1" = 'client' -a "$(id -u)" = '0' ]; then
	# Change node into a client node
	echo "node.master: false" >> /usr/share/elasticsearch/config/elasticsearch.yml
	echo "node.client: true" >> /usr/share/elasticsearch/config/elasticsearch.yml
	echo "node.data: false" >> /usr/share/elasticsearch/config/elasticsearch.yml
	echo "discovery.zen.ping.unicast.hosts: [\"elastic-master\"]" >> /usr/share/elasticsearch/config/elasticsearch.yml

	# Install kopf plugin
	plugin install lmenezes/elasticsearch-kopf/v2.1.1

	# Change the ownership of /usr/share/elasticsearch/data to elasticsearch
	chown -R elasticsearch:elasticsearch /usr/share/elasticsearch/data

	set -- su-exec elasticsearch /sbin/tini -- elasticsearch ${es_opts}
	#exec su-exec elasticsearch "$BASH_SOURCE" "$@"
fi

if [ "$1" = 'data' -a "$(id -u)" = '0' ]; then
	# Change node into a data node
	echo "node.master: false" >> /usr/share/elasticsearch/config/elasticsearch.yml
	echo "node.client: false" >> /usr/share/elasticsearch/config/elasticsearch.yml
	echo "node.data: true" >> /usr/share/elasticsearch/config/elasticsearch.yml
	echo "discovery.zen.ping.unicast.hosts: [\"elastic-master\"]" >> /usr/share/elasticsearch/config/elasticsearch.yml

	# Change the ownership of /usr/share/elasticsearch/data to elasticsearch
	chown -R elasticsearch:elasticsearch /usr/share/elasticsearch/data

	set -- su-exec elasticsearch /sbin/tini -- elasticsearch ${es_opts}
	#exec su-exec elasticsearch "$BASH_SOURCE" "$@"
fi

# As argument is not related to elasticsearch,
# then assume that user wants to run his own process,
# for example a `bash` shell to explore this image
exec "$@"
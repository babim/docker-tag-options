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

# set ID docker run
if [[ $STACK_NEW == true || $STACK_NEW == false ]];then
	export auid=${auid:-100}
	export agid=${agid:-$101}
	export auser=${auser:-elstack}
	export aguser=${aguser:-$auser}
else
	export auid=${auid:-100}
	export agid=${agid:-$101}
	export auser=${auser:-elasticsearch}
	export aguser=${aguser:-$auser}
fi

	if [[ -z "${auid}" ]] || [[ "$auid" != "100" ]]; then
	  echo "start"
	elif [[ "$auid" == "0" ]] || [[ "$aguid" == "0" ]]; then
		echo "run in user root"
		export auser=root
	elif id $auid >/dev/null 2>&1; then
	        echo "UID exists. Please change UID"
	else
		if id $auser >/dev/null 2>&1; then
		        echo "user exists"
			if [[ -f /etc/alpine-release ]]; then
			# usermod alpine
				deluser $auser && delgroup $aguser
				addgroup -g $agid $aguser && adduser -D -H -G $aguser -s /bin/false -u $auid $auser
			else
			# usermod ubuntu/debian
				usermod -u $auid $auser
				groupmod -g $agid $aguser
			fi
		else
			if [[ -f /etc/alpine-release ]]; then
			# create user alpine
				addgroup -g $agid $aguser && adduser -D -H -G $aguser -s /bin/false -u $auid $auser
			else
			# create user ubuntu/debian
				groupadd -g $agid $aguser && useradd --system --uid $auid --shell /usr/sbin/nologin -g $aguser $auser
			fi
		fi
	fi

es_opts=''

# Add elasticsearch as command if needed
if [ "${1:0:1}" = '-' ]; then
	set -- elasticsearch "$@" ${es_opts}
fi

# Drop root privileges if we are running elasticsearch
# allow the container to be started with `--user`
if [ "$1" = 'elasticsearch' -a "$(id -u)" = '0' ]; then
	# Change the ownership of /usr/share/elasticsearch/data to elasticsearch
	chown -R $auser:$aguser /usr/share/elasticsearch/data

	set -- su-exec $auser /sbin/tini -s -- "$@" ${es_opts}
	#exec su-exec elasticsearch "$BASH_SOURCE" "$@"
fi

if [ "$1" = 'kopf' -a "$(id -u)" = '0' ]; then
	# Install kopf plugin
	plugin install lmenezes/elasticsearch-kopf/v2.1.1

	# Change the ownership of /usr/share/elasticsearch/data to elasticsearch
	chown -R $auser:$aguser /usr/share/elasticsearch/data

	set -- su-exec $auser tini -- "$@" ${es_opts}
	#exec su-exec elasticsearch "$BASH_SOURCE" "$@"
fi

if [ "$1" = 'master' -a "$(id -u)" = '0' ]; then
	# Change node into a master node
	echo "node.master: true" >> /usr/share/elasticsearch/config/elasticsearch.yml
	echo "node.client: false" >> /usr/share/elasticsearch/config/elasticsearch.yml
	echo "node.data: false" >> /usr/share/elasticsearch/config/elasticsearch.yml

	# Change the ownership of /usr/share/elasticsearch/data to elasticsearch
	chown -R $auser:$aguser /usr/share/elasticsearch/data

	set -- su-exec $auser /sbin/tini -- "$@" ${es_opts}
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
	chown -R $auser:$aguser /usr/share/elasticsearch/data

	set -- su-exec $auser /sbin/tini -- "$@" ${es_opts}
	#exec su-exec elasticsearch "$BASH_SOURCE" "$@"
fi

if [ "$1" = 'data' -a "$(id -u)" = '0' ]; then
	# Change node into a data node
	echo "node.master: false" >> /usr/share/elasticsearch/config/elasticsearch.yml
	echo "node.client: false" >> /usr/share/elasticsearch/config/elasticsearch.yml
	echo "node.data: true" >> /usr/share/elasticsearch/config/elasticsearch.yml
	echo "discovery.zen.ping.unicast.hosts: [\"elastic-master\"]" >> /usr/share/elasticsearch/config/elasticsearch.yml

	# Change the ownership of /usr/share/elasticsearch/data to elasticsearch
	chown -R $auser:$aguser /usr/share/elasticsearch/data

	set -- su-exec $auser /sbin/tini -- "$@" ${es_opts}
	#exec su-exec elasticsearch "$BASH_SOURCE" "$@"
fi

# As argument is not related to elasticsearch,
# then assume that user wants to run his own process,
# for example a `bash` shell to explore this image
exec "$@"
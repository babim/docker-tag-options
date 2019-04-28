#!/bin/bash
#  ____        _     _
# | __ )  __ _| |__ (_)_ __ ___
# |  _ \ / _` | '_ \| | '_ ` _ \
# | |_) | (_| | |_) | | | | | | |
# |____/ \__,_|_.__/|_|_| |_| |_|

set -e

# copy config supervisor
if [ -d "/etc/supervisor" ] && [ -d "/etc-start/supervisor" ];then
	[[ ! -f "/etc/supervisor/supervisord.conf" ]] && cp -R -f /etc-start/supervisor/* /etc/supervisor || say "no need copy supervisor config"
fi
[[ -z "`ls ${1}`" ]]  

# copy config soft config
if [ -d "/usr/share/${SOFT}/config" ] && [ -d "/etc-start/${SOFT}" ];then
	[[ -z "`ls /usr/share/${SOFT}/config`" ]]  && cp -R -f /etc-start/${SOFT}/* /usr/share/${SOFT}/config || say "no need copy ${SOFT} config"
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

	if [[ -z "${auid}" ]] || [[ "$auid" == "100" ]]; then
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

umask 0002

declare -a es_opts

while IFS='=' read -r envvar_key envvar_value
do
    # Elasticsearch env vars need to have at least two dot separated lowercase words, e.g. `cluster.name`
    if [[ "$envvar_key" =~ ^[a-z0-9_]+\.[a-z0-9_]+ ]]; then
        if [[ ! -z $envvar_value ]]; then
          es_opt="-E${envvar_key}=${envvar_value}"
          es_opts+=("${es_opt}")
        fi
    fi
done < <(env)

export ES_JAVA_OPTS="-Des.cgroups.hierarchy.override=/ $ES_JAVA_OPTS"

# Determine if x-pack is enabled
if bin/elasticsearch-plugin list -s | grep -q x-pack; then
    if [[ -n "$ELASTIC_PASSWORD" ]]; then
        [[ -f config/elasticsearch.keystore ]] ||  bin/elasticsearch-keystore create
        echo "$ELASTIC_PASSWORD" | bin/elasticsearch-keystore add -x 'bootstrap.password'
    fi
fi

# Add elasticsearch as command if needed
if [ "${1:0:1}" = '-' ]; then
	set -- elasticsearch "$@" ${es_opts}
fi

# Drop root privileges if we are running elasticsearch
# allow the container to be started with `--user`
if [ "$1" = 'elasticsearch' -a "$(id -u)" = '0' ]; then
	# Change the ownership of user-mutable directories to elasticsearch
	chown -R $auser:$aguser /usr/share/elasticsearch/{data,logs}

	set -- su-exec $auser /sbin/tini -s -- "$@" ${es_opts}
fi

exec "$@"

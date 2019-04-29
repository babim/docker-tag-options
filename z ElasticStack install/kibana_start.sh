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
	export auser=${auser:-kibana}
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
		        echo "create user"
			if [[ -f /etc/alpine-release ]]; then
			# create user alpine
				addgroup -g $agid $aguser && adduser -D -H -G $aguser -s /bin/false -u $auid $auser
			else
			# create user ubuntu/debian
				groupadd -g $agid $aguser && useradd --system --uid $auid --shell /usr/sbin/nologin -g $aguser $auser
			fi
		fi
	fi

# Add kibana as command if needed
if [[ "$1" == -* ]]; then
	set -- kibana "$@"
fi

# Run as user "kibana" if the command is "kibana"
if [ "$1" = 'kibana' ]; then
	if [ "$ELASTICSEARCH_URL" ]; then
		sed -ri "s!^(\#\s*)?(elasticsearch\.url:).*!\2 '$ELASTICSEARCH_URL'!" /usr/share/kibana/config/kibana.yml
	fi

	set -- su-exec $auser /sbin/tini -- "$@"
fi

exec "$@"
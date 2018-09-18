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

# Add kibana as command if needed
if [[ "$1" == -* ]]; then
	set -- kibana "$@"
fi

# Run as user "kibana" if the command is "kibana"
if [ "$1" = 'kibana' ]; then
	if [ "$ELASTICSEARCH_URL" ]; then
		sed -ri "s!^(\#\s*)?(elasticsearch\.url:).*!\2 '$ELASTICSEARCH_URL'!" /usr/share/kibana/config/kibana.yml
	fi

	set -- su-exec kibana /sbin/tini -- "$@"
fi

exec "$@"
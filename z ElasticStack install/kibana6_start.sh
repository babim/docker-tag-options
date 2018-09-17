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

declare -a kb_opts

# Parse env vars of the form: kibana.setting=value
while IFS='=' read -r envvar_key envvar_value
do
    # Elasticsearch env vars need to have at least two dot separated lowercase words, e.g. `cluster.name`
    if [[ "$envvar_key" =~ ^[a-z0-9_]+\.[a-z0-9_]+ ]]; then
        if [[ ! -z $envvar_value ]]; then
          kb_opt="--${envvar_key}=${envvar_value}"
          kb_opts+=("${kb_opt}")
        fi
    fi
done < <(env)

# Parse env vars of the form: KIBANA_SETTING=value
while IFS='=' read -r envvar_key envvar_value
do
    # Elasticsearch env vars need to have at least two dot separated lowercase words, e.g. `CLUSTER_NAME`
    if [[ "$envvar_key" =~ ^KIBANA_[A-Z0-9_]+ ]]; then
        kib_name=`echo "${envvar_key#"KIBANA_"}" | tr '[:upper:]' '[:lower:]' | tr _ .`
        if [[ ! -z $envvar_value ]]; then
          kb_opt="--${kib_name}=${envvar_value}"
          kb_opts+=("${kb_opt}")
        fi
    fi
done < <(env)

# Add kibana as command if needed
if [[ "$1" == -* ]]; then
	set -- kibana "$@"
fi

# Run as user "kibana" if the command is "kibana"
if [ "$1" = 'kibana' -a "$(id -u)" = '0' ]; then
	set -- su-exec kibana /sbin/tini -s -- "$@" "${kb_opts[@]}"
fi

exec "$@"

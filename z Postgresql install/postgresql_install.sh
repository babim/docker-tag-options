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
if [[ -f /etc/debian_version ]] || [[ -f /etc/lsb-release ]]; then
	# set environment
	DOWN_URL="--no-check-certificate https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20Postgresql%20install"
	export DEBIAN_FRONTEND=noninteractive
		PG_APP_HOME=${PG_APP_HOME:-"/etc/docker-postgresql"} \
		PG_USER=${PG_USER:-"postgres"} \
		PG_HOME=${PG_HOME:-"/var/lib/postgresql"} \
		PG_RUNDIR=${PG_RUNDIR:-"/run/postgresql"} \
		PG_LOGDIR=${PG_LOGDIR:-"/var/log/postgresql"} \
		PG_CERTDIR=${PG_CERTDIR:-"/etc/postgresql/certs"}
	# install depend
		wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
		&& echo "deb http://apt.postgresql.org/pub/repos/apt/ $OSDEB-pgdg main" > /etc/apt/sources.list.d/pgdg.list \
		&& apt-get update \
		&& apt-get install -y acl sudo \
		postgresql-${PG_VERSION} postgresql-client-${PG_VERSION} postgresql-contrib-${PG_VERSION} \
		&& ln -sf ${PG_DATADIR}/postgresql.conf /etc/postgresql/${PG_VERSION}/main/postgresql.conf \
		&& ln -sf ${PG_DATADIR}/pg_hba.conf /etc/postgresql/${PG_VERSION}/main/pg_hba.conf \
		&& ln -sf ${PG_DATADIR}/pg_ident.conf /etc/postgresql/${PG_VERSION}/main/pg_ident.conf
	# download config files
		[[ ! -f /entrypoint.sh ]] || rm -f /start.sh
		FILETEMP=/entrypoint.sh
		[[ ! -f $FILETEMP ]] || rm -f $FILETEMP
		wget -O $FILETEMP $DOWN_URL$FILETEMP
		chmod 755 $FILETEMP
	# clean
		rm -rf ${PG_HOME} \
		&& apt-get purge -y wget curl && rm -rf /var/lib/apt/lists/*		
else
    echo "Not support your OS"
    exit
fi
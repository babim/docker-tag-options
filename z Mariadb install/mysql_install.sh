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
if [[ -f /etc/debian_version ]]; then
	DOWN_URL="https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20Mariadb%20install"
	# add Percona's repo for xtrabackup (which is useful for Galera)
		curl -s $DOWN_URL/percona_repo.sh | bash

	# add repo Mysql
		curl -s $DOWN_URL/mysql_repo.sh | bash

	# install gosu
		curl -s $DOWN_URL/gosu_install.sh | bash

	mkdir /docker-entrypoint-initdb.d

	# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
	groupadd -r mysql && useradd -r -g mysql mysql

	export DEBIAN_FRONTEND=noninteractive
	# the "/var/lib/mysql" stuff here is because the mysql-server postinst doesn't have an explicit way to disable the mysql_install_db codepath besides having a database already "configured" (ie, stuff in /var/lib/mysql/mysql)
	# also, we set debconf keys to make APT a little quieter
	{ \
			echo mysql-community-server mysql-community-server/data-dir select ''; \
			echo mysql-community-server mysql-community-server/root-pass password ''; \
			echo mysql-community-server mysql-community-server/re-root-pass password ''; \
			echo mysql-community-server mysql-community-server/remove-test-db select false; \
		} | debconf-set-selections \
		&& apt-get update && apt-get install -y mysql-server && rm -rf /var/lib/apt/lists/* \
		&& rm -rf /var/lib/mysql && mkdir -p /var/lib/mysql /var/run/mysqld \
		&& chown -R mysql:mysql /var/lib/mysql /var/run/mysqld
	# ensure that /var/run/mysqld (used for socket and lock files) is writable regardless of the UID our mysqld instance ends up having at runtime
		chmod 777 /var/run/mysqld
	# comment out a few problematic configuration values
		find /etc/mysql/ -name '*.cnf' -print0 \
			| xargs -0 grep -lZE '^(bind-address|log)' \
			| xargs -rt -0 sed -Ei 's/^(bind-address|log)/#&/'
	# don't reverse lookup hostnames, they are usually another container
		echo '[mysqld]\nskip-host-cache\nskip-name-resolve' > /etc/mysql/conf.d/docker.cnf

	# install "pwgen" for randomizing passwords
	apt-get install -y --no-install-recommends pwgen

	# download entrypoint
		FILETEMP=/start.sh
		[[ ! -f $FILETEMP ]] || rm -f $FILETEMP
		wget -O $FILETEMP --no-check-certificate $DOWN_URL/start.sh && \
		chmod 755 $FILETEMP
	# download backup script
		wget -O /backup.sh --no-check-certificate $DOWN_URL/backup.sh && \
		chmod 755 /backup.sh
	# prepare etc start
		curl -s $DOWN_URL/prepare_final.sh | bash
	# remove packages
		apt-get purge wget curl -y

else
    echo "Not support your OS"
    exit
fi
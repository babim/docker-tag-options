#!/bin/bash
#  ____        _     _
# | __ )  __ _| |__ (_)_ __ ___
# |  _ \ / _` | '_ \| | '_ ` _ \
# | |_) | (_| | |_) | | | | | | |
# |____/ \__,_|_.__/|_|_| |_| |_|

if [[ "$TYPESQL" == "mariadb" ]];then
	# add repo Mariadb
	apt-get install software-properties-common dirmngr gnupg -y
	gpg --no-tty --recv-keys --keyserver keyserver.ubuntu.com 0xF1656F24C74CD1D8
	# set version
	#export MARIADB_MAJOR=10.0
	wget --no-check-certificate -O - https://downloads.mariadb.com/MariaDB/mariadb_repo_setup | bash

elif [[ "$TYPESQL" == "mysql" ]] || [[ "$TYPESQL" == "mysql5" ]];then
	# add repo Mysql
	set -ex; \
	# gpg: key 5072E1F5: public key "MySQL Release Engineering <mysql-build@oss.oracle.com>" imported
		key='A4A9406876FCBD3C456770C88C718D3B5072E1F5'; \
		export GNUPGHOME="$(mktemp -d)"; \
		gpg --no-tty --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
		gpg --export "$key" > /etc/apt/trusted.gpg.d/mysql.gpg; \
		rm -rf "$GNUPGHOME"; \
		apt-key list > /dev/null
	# set version
	#export MYSQL_MAJOR=5.5
	#export MYSQL_VERSION=5.5.61
	echo "deb http://repo.mysql.com/apt/debian/ $OSDEB mysql-${MYSQL_MAJOR}" > /etc/apt/sources.list.d/mysql.list
else
	echo "Not support your sql"
fi

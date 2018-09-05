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

	mkdir /docker-entrypoint-initdb.d

	# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
	groupadd -r mysql && useradd -r -g mysql mysql

	# install mysql over repo with major version
	export DEBIAN_FRONTEND=noninteractive
	wget -q --no-check-certificate "https://cdn.mysql.com/Downloads/MySQL-$MYSQL_MAJOR/mysql-$MYSQL_VERSION-linux-glibc2.12-x86_64.tar.gz" -O mysql.tar.gz \
		&& mkdir /usr/local/mysql \
		&& tar -xzf mysql.tar.gz -C /usr/local/mysql --strip-components=1 \
		&& rm mysql.tar.gz \
		&& rm -rf /usr/local/mysql/mysql-test /usr/local/mysql/sql-bench \
		&& rm -rf /usr/local/mysql/bin/*-debug /usr/local/mysql/bin/*_embedded \
		&& find /usr/local/mysql -type f -name "*.a" -delete \
		&& apt-get update && apt-get install -y binutils && rm -rf /var/lib/apt/lists/* \
		&& { find /usr/local/mysql -type f -executable -exec strip --strip-all '{}' + || true; } \
		&& apt-get purge -y --auto-remove binutils
	export PATH=$PATH:/usr/local/mysql/bin:/usr/local/mysql/scripts

	mkdir -p /etc/mysql/conf.d \
		&& { \
			echo '[mysqld]'; \
			echo 'skip-host-cache'; \
			echo 'skip-name-resolve'; \
			echo 'datadir = /var/lib/mysql'; \
			echo '!includedir /etc/mysql/conf.d/'; \
		} > /etc/mysql/my.cnf

	# ensure that /var/run/mysqld (used for socket and lock files) is writable regardless of the UID our mysqld instance ends up having at runtime
	mkdir -p /var/lib/mysql /var/run/mysqld \
		&& chown -R mysql:mysql /var/lib/mysql /var/run/mysqld
		chmod 777 /var/run/mysqld

	# install "pwgen" for randomizing passwords
	apt-get install -y --no-install-recommends pwgen

	# download entrypoint
		[[ ! -f /start.sh ]] || rm -f /start.sh
		wget --no-check-certificate $DOWN_URL/start.sh && \
		chmod 755 /start.sh
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
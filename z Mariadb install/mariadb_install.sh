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

# add repo Mariadb
set -ex; \
	key='199369E5404BD5FC7D2FE43BCBCB082A1BB943DB'; \
	export GNUPGHOME="$(mktemp -d)"; \
	gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
	gpg --export "$key" > /etc/apt/trusted.gpg.d/mariadb.gpg; \
	rm -rf "$GNUPGHOME"; \
	key='177F4010FE56CA3336300305F1656F24C74CD1D8'; \
	export GNUPGHOME="$(mktemp -d)"; \
	gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
	gpg --export "$key" >> /etc/apt/trusted.gpg.d/mariadb.gpg; \
	rm -rf "$GNUPGHOME"; \
	key='430BDF5C56E7C94E848EE60C1C4CBDCDCD2EFD2A'; \
	export GNUPGHOME="$(mktemp -d)"; \
	gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
	gpg --export "$key" >> /etc/apt/trusted.gpg.d/mariadb.gpg; \
	rm -rf "$GNUPGHOME"; \
	key='4D1BB29D63D98E422B2113B19334A25F8507EFA5'; \
	export GNUPGHOME="$(mktemp -d)"; \
	gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
	gpg --export "$key" >> /etc/apt/trusted.gpg.d/mariadb.gpg; \
	command -v gpgconf > /dev/null && gpgconf --kill all || :; \
	rm -rf "$GNUPGHOME"; \
	apt-key list > /dev/null

# add Percona's repo for xtrabackup (which is useful for Galera)
echo "deb https://repo.percona.com/apt $OSDEB main" > /etc/apt/sources.list.d/percona.list \
	&& { \
		echo 'Package: *'; \
		echo 'Pin: release o=Percona Development Team'; \
		echo 'Pin-Priority: 998'; \
	} > /etc/apt/preferences.d/percona

# add repo Mysql
set -ex; \
# gpg: key 5072E1F5: public key "MySQL Release Engineering <mysql-build@oss.oracle.com>" imported
	key='A4A9406876FCBD3C456770C88C718D3B5072E1F5'; \
	export GNUPGHOME="$(mktemp -d)"; \
	gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
	gpg --export "$key" > /etc/apt/trusted.gpg.d/mysql.gpg; \
	rm -rf "$GNUPGHOME"; \
	apt-key list > /dev/null

mkdir /docker-entrypoint-initdb.d

# set version
#export MARIADB_MAJOR=10.0

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
groupadd -r mysql && useradd -r -g mysql mysql

# install mysql over repo with major version
export DEBIAN_FRONTEND=noninteractive
set -e;\
echo "deb http://ftp.osuosl.org/pub/mariadb/repo/$MARIADB_MAJOR/debian $OSDEB main" > /etc/apt/sources.list.d/mariadb.list \
	&& { \
		echo 'Package: *'; \
		echo 'Pin: release o=MariaDB'; \
		echo 'Pin-Priority: 999'; \
	} > /etc/apt/preferences.d/mariadb
set -e;\
	{ \
		echo "mariadb-server-$MARIADB_MAJOR" mysql-server/root_password password 'unused'; \
		echo "mariadb-server-$MARIADB_MAJOR" mysql-server/root_password_again password 'unused'; \
	} | debconf-set-selections \
	&& apt-get update \
	&& apt-get install -y \
		mariadb-server \
		percona-xtrabackup \
		socat
# comment out any "user" entires in the MySQL config ("docker-entrypoint.sh" or "--user" will handle user switching)
	sed -ri 's/^user\s/#&/' /etc/mysql/my.cnf /etc/mysql/conf.d/*
# purge and re-create /var/lib/mysql with appropriate ownership
	rm -rf /var/lib/mysql && mkdir -p /var/lib/mysql var/run/mysqld \
	&& chown -R mysql:mysql /var/lib/mysql /var/run/mysqld
# ensure that /var/run/mysqld (used for socket and lock files) is writable regardless of the UID our mysqld instance ends up having at runtime
	chmod 777 /var/run/mysqld
# comment out a few problematic configuration values
	find /etc/mysql/ -name '*.cnf' -print0 \
		| xargs -0 grep -lZE '^(bind-address|log)' \
		| xargs -rt -0 sed -Ei 's/^(bind-address|log)/#&/'
# don't reverse lookup hostnames, they are usually another container
	echo '[mysqld]\nskip-host-cache\nskip-name-resolve' > /etc/mysql/conf.d/docker.cnf

# download entrypoint
	[[ ! -f /start.sh ]] || rm -f /start.sh
	cd / && \
	wget --no-check-certificate https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20Mariadb%20install/start.sh && \
	chmod 755 start.sh
# download backup script
	wget --no-check-certificate https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20Mariadb%20install/backup.sh && \
	chmod 755 start.sh
# prepare etc start
    curl -s https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20PHP%20install/prepare_final.sh | bash
# remove packages
	apt-get purge wget curl -y

else
    echo "Not support your OS"
    exit
fi
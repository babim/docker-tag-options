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
	# set host download
		DOWN_URL="https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20Mariadb%20install"
	# Set frontend debian
		export DEBIAN_FRONTEND=noninteractive
	apt-get update
	# install "pwgen" for randomizing passwords
	# install "tzdata" for /usr/share/zoneinfo/
		apt-get install -y --no-install-recommends pwgen dirmngr tzdata apt-transport-https gnupg supervisor
	# add Percona's repo for xtrabackup (which is useful for Galera)
		wget --no-check-certificate -O - $DOWN_URL/percona_repo.sh | bash
	# install gosu
		wget --no-check-certificate -O - $DOWN_URL/gosu_install.sh | bash
	# add repo Mariadb, Mysql
		wget --no-check-certificate -O - $DOWN_URL/mariadb_repo.sh | bash
	# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
		groupadd -r mysql && useradd -r -g mysql mysql
	# make docker-entrypoint-initdb
		mkdir /docker-entrypoint-initdb.d
	# set loop
		finish() {
			# download entrypoint
				FILETEMP=/start.sh
				[[ ! -f $FILETEMP ]] || rm -f $FILETEMP
				wget -O $FILETEMP --no-check-certificate $DOWN_URL/start.sh && \
				chmod 755 $FILETEMP
			# Supervisor config
				[[ -d /var/log/supervisor ]] || mkdir -p /var/log/supervisor/
				[[ -d /etc/supervisor/conf.d ]] || mkdir -p /etc/supervisor/conf.d/
			# download sypervisord config
			FILETEMP=/etc/supervisor/supervisord.conf
				[[ ! -f $FILETEMP ]] || rm -f $FILETEMP
				wget -O $FILETEMP $DOWN_URL/supervisor/supervisord.conf
			FILETEMP=/etc/supervisor/conf.d/mysql.conf
				[[ ! -f $FILETEMP ]] || rm -f $FILETEMP
				wget -O $FILETEMP $DOWN_URL/supervisor/conf.d/mysql.conf
			# prepare etc start
			wget --no-check-certificate -O - $DOWN_URL/prepare_final.sh | bash
				[[ ! -d /etc-start ]] || rm -rf /etc-start

			# download backup script
				wget -O /backup.sh --no-check-certificate $DOWN_URL/backup.sh && \
				chmod 755 /backup.sh
			# prepare etc start
				wget --no-check-certificate -O - $DOWN_URL/prepare_final.sh | bash
			# remove packages
				apt-get purge wget -y
			}
			
	if [[ "$TYPESQL" == "mariadb" ]] || [[ "$TYPESQL" == "" ]];then
		# install mysql over repo with major version
		set -e;\
			{ \
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
			&& apt-get install -y --force-yes \
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

		# finish
		finish

	elif [[ "$TYPESQL" == "mysql" ]];then
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

		# finish
		finish

	elif [[ "$TYPESQL" == "mysql5" ]];then
		# install mysql over repo with major version
		FILETEMP=mysql.tar.gz
		wget -q --no-check-certificate "https://cdn.mysql.com/Downloads/MySQL-$MYSQL_MAJOR/mysql-$MYSQL_VERSION-linux-glibc2.12-x86_64.tar.gz" -O $FILETEMP \
			&& mkdir /usr/local/mysql \
			&& tar -xzf $FILETEMP -C /usr/local/mysql --strip-components=1 \
			&& rm $FILETEMP \
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

		# finish
		finish
fi
else
    echo "Not support your OS"
    exit
fi
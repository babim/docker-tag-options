#!/bin/bash
#  ____        _     _
# | __ )  __ _| |__ (_)_ __ ___
# |  _ \ / _` | '_ \| | '_ ` _ \
# | |_) | (_| | |_) | | | | | | |
# |____/ \__,_|_.__/|_|_| |_| |_|

# Stop script on NZEC
set -e
# Stop script if unbound variable found (use ${var:-} if intentional)
# set -u
# By default cmd1 | cmd2 returns exit code of cmd2 regardless of cmd1 success
# This is causing it to fail
set -o pipefail

#####################################
    ####### Set download tool #######
    ####### and load library ########
# check has package
function    machine_has() {
        hash "$1" > /dev/null 2>&1
        return $?; }
# Check and set download tool
echo "Check and set download tool..."
if machine_has "curl"; then
    source <(curl -s https://raw.githubusercontent.com/babim/docker-tag-options/master/lib/libbash)
elif machine_has "wget"; then
    source <(wget -qO- https://raw.githubusercontent.com/babim/docker-tag-options/master/lib/libbash)
else
    echo "without download tool"
    sleep 3
    exit 1
fi
download_option
#####################################

# need root to run
	require_root

# set loop
# finish after install app
finish() {
## download entrypoint
	FILETEMP=start.sh
		$download_save /$FILETEMP $DOWN_URL/$FILETEMP && \
		set_filefolder_mod 755 /$FILETEMP
## Supervisor
	install_supervisor
	### Supervisor config
		create_folder /var/log/supervisor/
		create_folder /etc/supervisor/conf.d/
	### download sypervisord config
	FILETEMP=/etc/supervisor/supervisord.conf
		$download_save $FILETEMP $DOWN_URL/supervisor/supervisord.conf
	FILETEMP=/etc/supervisord.conf
		create_symlink $FILETEMP /etc/supervisor/supervisord.conf
	### mysql
	FILETEMP=/etc/supervisor/conf.d/mysql.conf
	 	$download_save $FILETEMP $DOWN_URL/supervisor/conf.d/mysql.conf
## download backup script
	FILETEMP=backup.sh
		$download_save /$FILETEMP $DOWN_URL/$FILETEMP && \
		set_filefolder_mod 755 /$FILETEMP
## prepare etc start
	run_url $DOWN_URL/prepare_final.sh
## clean
	clean_package
	clean_os	
}
# purge and re-create /var/lib/mysql with appropriate ownership
recreate_mysql() {
## purge and re-create
	say "set folder owner.."
	remove_folder /var/lib/mysql && create_folder /var/lib/mysql var/run/mysqld \
	&& set_filefolder_owner mysql:mysql /var/lib/mysql /var/run/mysqld
## ensure that /var/run/mysqld (used for socket and lock files) is writable regardless of the UID our mysqld instance ends up having at runtime
	say "set folder mod.."
	set_filefolder_mod 777 /var/run/mysqld
## comment out a few problematic configuration values
	say "find beginning.."
	find /etc/mysql/ -name '*.cnf' -print0 \
		| xargs -0 grep -lZE '^(bind-address|log)' \
		| xargs -rt -0 sed -Ei 's/^(bind-address|log)/#&/'
## don't reverse lookup hostnames, they are usually another container
	echo '[mysqld]\nskip-host-cache\nskip-name-resolve' > /etc/mysql/conf.d/docker.cnf
}

# install by OS
echo 'Check OS'
if [[ -f /etc/debian_version ]]; then
	# uninstall app after install
		export UNINSTALL="${DOWNLOAD_TOOL}"
	# Set app version
		export TYPESQL=${TYPESQL:-mariadb}
		export MARIADB_MAJOR=${MARIADB_MAJOR:-10.4}
		export MYSQL_MAJOR=${MYSQL_MAJOR:-5.6}
		export MYSQL_VERSION=${MYSQL_VERSION:-5.5.61}
	# set host download
		export DOWN_URL="https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20Mariadb%20install"
	# Set frontend debian
		debian_cmd_interface
	# install "pwgen" for randomizing passwords
	# install "tzdata" for /usr/share/zoneinfo/
		install_package pwgen tzdata apt-transport-https ca-certificates
	# add Percona's repo for xtrabackup (which is useful for Galera)
		run_url $DOWN_URL/percona_repo.sh
	# install gosu
		install_gosu
	# add repo Mariadb, Mysql
		run_url $DOWN_URL/mariadb_repo.sh
	# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
		groupadd -r mysql && useradd -r -g mysql mysql
	# make docker-entrypoint-initdb
		create_folder /docker-entrypoint-initdb.d
			
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
			&& install_package \
				mariadb-server \
				percona-xtrabackup \
				socat
		# comment out any "user" entires in the MySQL config ("docker-entrypoint.sh" or "--user" will handle user switching)
			say "sed beginning.."
			sed -ri 's/^user\s/#&/' /etc/mysql/my.cnf /etc/mysql/conf.d/*
		# purge and re-create /var/lib/mysql with appropriate ownership
			recreate_mysql
		# finish
			finish

	elif [[ "$TYPESQL" == "mysql" ]];then
		# # the "/var/lib/mysql" stuff here is because the mysql-server postinst doesn't have an explicit way to disable the mysql_install_db codepath besides having a database already "configured" (ie, stuff in /var/lib/mysql/mysql)
		# # also, we set debconf keys to make APT a little quieter
		# { \
		# 		echo mysql-community-server mysql-community-server/data-dir select ''; \
		# 		echo mysql-community-server mysql-community-server/root-pass password ''; \
		# 		echo mysql-community-server mysql-community-server/re-root-pass password ''; \
		# 		echo mysql-community-server mysql-community-server/remove-test-db select false; \
		# 	} | debconf-set-selections \
			install_package mysql-server && remove_filefolder /var/lib/apt/lists/*
		# purge and re-create /var/lib/mysql with appropriate ownership
			recreate_mysql
		# finish
			finish

	elif [[ "$TYPESQL" == "mysql5" ]];then
		# install mysql over repo with major version
		FILETEMP=mysql.tar.gz
		check_file $FILETEMP && $download_save $FILETEMP "https://cdn.mysql.com/Downloads/MySQL-$MYSQL_MAJOR/mysql-$MYSQL_VERSION-linux-glibc2.12-x86_64.tar.gz" \
			&& create_folder /usr/local/mysql \
			&& tar_extract $FILETEMP /usr/local/mysql --strip-components=1 \
			&& remove_filefolder $FILETEMP \
			&& remove_filefolder /usr/local/mysql/mysql-test /usr/local/mysql/sql-bench \
			&& remove_filefolder /usr/local/mysql/bin/*-debug /usr/local/mysql/bin/*_embedded \
			&& find /usr/local/mysql -type f -name "*.a" -delete \
			&& install_package binutils && remove_filefolder /var/lib/apt/lists/* \
			&& { find /usr/local/mysql -type f -executable -exec strip --strip-all '{}' + || true; } \
			&& remove_package binutils
		export PATH=$PATH:/usr/local/mysql/bin:/usr/local/mysql/scripts

		create_folder /etc/mysql/conf.d \
			&& { \
				echo '[mysqld]'; \
				echo 'skip-host-cache'; \
				echo 'skip-name-resolve'; \
				echo 'datadir = /var/lib/mysql'; \
				echo '!includedir /etc/mysql/conf.d/'; \
			} > /etc/mysql/my.cnf

		# ensure that /var/run/mysqld (used for socket and lock files) is writable regardless of the UID our mysqld instance ends up having at runtime
			create_folder /var/lib/mysql /var/run/mysqld
			set_filefolder_owner mysql:mysql /var/lib/mysql /var/run/mysqld
			set_filefolder_mod 777 /var/run/mysqld

		# finish
			finish
	fi
else
    say_err "Not support your OS"
    exit 1
fi
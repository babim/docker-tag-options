#!/bin/bash
#  ____        _     _
# | __ )  __ _| |__ (_)_ __ ___
# |  _ \ / _` | '_ \| | '_ ` _ \
# | |_) | (_| | |_) | | | | | | |
# |____/ \__,_|_.__/|_|_| |_| |_|

# need root to run
	require_root

	# Set app version
		export TYPESQL=${TYPESQL:-mariadb}
		export MARIADB_MAJOR=${MARIADB_MAJOR:-10.4}
		export MYSQL_MAJOR=${MYSQL_MAJOR:-5.6}
		export MYSQL_VERSION=${MYSQL_VERSION:-5.5.61}

if [[ -f /etc/lsb-release ]] || [[ -f /etc/debian_version ]]; then
	if [[ "$TYPESQL" == "mariadb" ]];then
		# add repo Mariadb
		install_package software-properties-common dirmngr gnupg
		if [[ "$osname" == "wheezy" ]] || [[ "$OSDEB" == "trusty" ]];then
			install_package python-software-properties
		fi
		debian_add_repo_key 0xF1656F24C74CD1D8
		debian_add_repo_key 0xCBCB082A1BB943DB
		# set version
		if [[ "$OSDEB" == "trusty" ]];then
			add-apt-repository "deb [arch=amd64,i386,ppc64el] http://mirror.truenetwork.ru/mariadb/repo/$MARIADB_MAJOR/ubuntu $OSDEB main"
		else
			add-apt-repository "deb [arch=amd64,i386,ppc64el] http://mirror.truenetwork.ru/mariadb/repo/$MARIADB_MAJOR/debian $OSDEB main"
		fi

	elif [[ "$TYPESQL" == "mysql" ]] || [[ "$TYPESQL" == "mysql5" ]];then
		install_package lsb-release gnupg
		FILETEMP=mysql-apt-config_0.8.12-1_all.deb
			$download_save $FILETEMP https://dev.mysql.com/get/$FILETEMP
			install_package $FILETEMP && remove_file $FILETEMP keystrokes
		export MYSQLDEFAULT=8.0
		if [[ "$MYSQL_MAJOR" == "5.6" ]];then
			sed -i "s/${MYSQLDEFAULT}/5.6/" /etc/apt/sources.list.d/mysql.list
		elif [[ "$MYSQL_MAJOR" == "5.7" ]];then
			sed -i "s/${MYSQLDEFAULT}/5.7/" /etc/apt/sources.list.d/mysql.list
		elif [[ "$MYSQL_MAJOR" == "8.0" ]];then
			sed -i "s/${MYSQLDEFAULT}/8.0/" /etc/apt/sources.list.d/mysql.list
		fi

	# code add repo old
	# 	add repo Mysql
	# 	set -ex; \
	# 	gpg: key 5072E1F5: public key "MySQL Release Engineering <mysql-build@oss.oracle.com>" imported
	# 		key='A4A9406876FCBD3C456770C88C718D3B5072E1F5'; \
	# 		export GNUPGHOME="$(mktemp -d)"; \
	# 		gpg --no-tty --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
	# 		gpg --export "$key" > /etc/apt/trusted.gpg.d/mysql.gpg; \
	# 		rm -rf "$GNUPGHOME"; \
	# 		apt-key list > /dev/null
	# 	set version
	# 	export MYSQL_MAJOR=5.5
	# 	export MYSQL_VERSION=5.5.61
	# 	echo "deb http://repo.mysql.com/apt/debian/ $OSDEB mysql-${MYSQL_MAJOR}" > /etc/apt/sources.list.d/mysql.list
	else
		say_err "Not support your sql"
	fi

elif [[ -f /etc/redhat-release ]]; then
	if [[ "$TYPESQL" == "mariadb" ]];then
		# add repo Mariadb
		echo "[mariadb]" > /etc/yum.repos.d/mariadb.repo
		echo "name = MariaDB" >> /etc/yum.repos.d/mariadb.repo
		echo "baseurl = http://yum.mariadb.org/${MYSQL_MAJOR}/centos$OSDEB-amd64" >> /etc/yum.repos.d/mariadb.repo
		echo "gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB" >> /etc/yum.repos.d/mariadb.repo
		echo "gpgcheck=1" >> /etc/yum.repos.d/mariadb.repo

	elif [[ "$TYPESQL" == "mysql" ]] || [[ "$TYPESQL" == "mysql5" ]];then
		# add repo Mysql
		echo "[mysql-community]" > /etc/yum.repos.d/mysql.repo
		echo "name=MySQL Community Server" >> /etc/yum.repos.d/mysql.repo
		echo "baseurl=http://repo.mysql.com/yum/mysql-${MYSQL_MAJOR}-community/el/$OSDEB/$basearch/" >> /etc/yum.repos.d/mysql.repo
		echo "enabled=1" >> /etc/yum.repos.d/mysql.repo
		echo "gpgcheck=1" >> /etc/yum.repos.d/mysql.repo
		echo "gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-mysql" >> /etc/yum.repos.d/mysql.repo
	else
		say_err "Not support your sql"
	fi

else
    say_err "Not support your OS"
    exit 1
fi
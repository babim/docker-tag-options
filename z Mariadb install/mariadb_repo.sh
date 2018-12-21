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

if [[ -f /etc/lsb-release ]] || [[ -f /etc/debian_version ]]; then
	if [[ "$TYPESQL" == "mariadb" ]];then
		# add repo Mariadb
		apt-get install software-properties-common dirmngr gnupg -y
		if [[ "$OSDEB" == "wheezy" ]] || [[ "$OSDEB" == "trusty" ]];then
			apt-get install python-software-properties -y
		fi
		apt-key adv --no-tty --recv-keys --keyserver keyserver.ubuntu.com 0xF1656F24C74CD1D8
		apt-key adv --no-tty --recv-keys --keyserver keyserver.ubuntu.com 0xCBCB082A1BB943DB
		# set version
		if [[ "$OSDEB" == "trusty" ]];then
			add-apt-repository "deb [arch=amd64,i386,ppc64el] http://mirror.truenetwork.ru/mariadb/repo/$MARIADB_MAJOR/ubuntu $OSDEB main"
		else
			add-apt-repository "deb [arch=amd64,i386,ppc64el] http://mirror.truenetwork.ru/mariadb/repo/$MARIADB_MAJOR/debian $OSDEB main"
		fi

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
		echo "Not support your sql"
	fi

else
    echo "Not support your OS"
    exit
fi
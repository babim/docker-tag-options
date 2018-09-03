echo 'Check root'
if [ "x$(id -u)" != 'x0' ]; then
    echo 'Error: this script can only be executed by root'
    exit 1
fi
echo 'Check OS'
if [[ -f /etc/debian_version ]]; then

# set version
#export MARIADB_MAJOR=10.0

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
groupadd -r mysql && useradd -r -g mysql mysql

# install mysql over repo with major version
export DEBIAN_FRONTEND=noninteractive
echo "deb http://ftp.osuosl.org/pub/mariadb/repo/$MARIADB_MAJOR/debian $OSDEB main" > /etc/apt/sources.list.d/mariadb.list \
	&& { \
		echo 'Package: *'; \
		echo 'Pin: release o=MariaDB'; \
		echo 'Pin-Priority: 999'; \
	} > /etc/apt/preferences.d/mariadb

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

# install "pwgen" for randomizing passwords
apt-get install -y --no-install-recommends pwgen

# download entrypoint
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
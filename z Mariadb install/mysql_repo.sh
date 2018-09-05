	# add repo Mysql
	set -ex; \
	# gpg: key 5072E1F5: public key "MySQL Release Engineering <mysql-build@oss.oracle.com>" imported
		key='A4A9406876FCBD3C456770C88C718D3B5072E1F5'; \
		export GNUPGHOME="$(mktemp -d)"; \
		gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
		gpg --export "$key" > /etc/apt/trusted.gpg.d/mysql.gpg; \
		rm -rf "$GNUPGHOME"; \
		apt-key list > /dev/null
	# set version
	#export MYSQL_MAJOR=5.5
	#export MYSQL_VERSION=5.5.61
	echo "deb http://repo.mysql.com/apt/debian/ $OSDEB mysql-${MYSQL_MAJOR}" > /etc/apt/sources.list.d/mysql.list
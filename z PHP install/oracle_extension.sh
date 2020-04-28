#!/bin/bash
#  ____        _     _
# | __ )  __ _| |__ (_)_ __ ___
# |  _ \ / _` | '_ \| | '_ ` _ \
# | |_) | (_| | |_) | | | | | | |
# |____/ \__,_|_.__/|_|_| |_| |_|

# need root to run
	require_root

# set environment
setenvironment() {
	export ORACLE_VERSION=12.2.0.1.0
	PHP_VERSION=${PHP_VERSION:-false}
}

# install by OS
echo 'Check OS'
if [[ -f /etc/lsb-release ]] || [[ -f /etc/debian_version ]]; then
	# set environment
		setenvironment
		debian_cmd_interface
	# install package depend
		install_package unzip libaio-dev pkg-config libbson-1.0 libmongoc-1.0-0
	# install php depend
		has_value ${PHP_VERSION} && install_package php$PHP_VERSION-dev php-pear php-dev || say "not have php"
	# install oracle client	
		FILETEMP=instantclient-basic-linux.x64-$ORACLE_VERSION.zip
			check_file $FILETEMP && say "file $FILETEMP exist" 	|| $download_save $FILETEMP http://file.matmagoc.com/oracle/$FILETEMP
			unzip_extract $FILETEMP /usr/local/			&& remove_file $FILETEMP
		FILETEMP=instantclient-sdk-linux.x64-$ORACLE_VERSION.zip
			check_file $FILETEMP && say "file $FILETEMP exist" 	|| $download_save $FILETEMP http://file.matmagoc.com/oracle/$FILETEMP
			unzip_extract $FILETEMP /usr/local/			&& remove_file $FILETEMP
		FILETEMP=instantclient-sqlplus-linux.x64-$ORACLE_VERSION.zip
			check_file $FILETEMP && say "file $FILETEMP exist" 	|| $download_save $FILETEMP http://file.matmagoc.com/oracle/$FILETEMP
			unzip_extract $FILETEMP /usr/local/			&& remove_file $FILETEMP
		create_symlink 		/usr/local/instantclient_12_2 /usr/local/instantclient
		create_symlink 		/usr/local/instantclient/libclntsh.so.12.1 /usr/local/instantclient/libclntsh.so
		create_symlink 		/usr/local/instantclient/sqlplus /usr/bin/sqlplus
		echo 'instantclient,/usr/local/instantclient' 			| pecl install oci8
		if check_folder /etc/php/; then
			FILETEMP=conf.d/30-oci8.ini
			for VARIABLE in /etc/php/*; do
				if [ -f "$VARIABLE/$FILETEMP" ]; then
					echo "extension=oci8.so" > $VARIABLE/$FILETEMP
				fi
			done
		fi

# OS - other
else
    say_err "Not support your OS"
    exit 1
fi
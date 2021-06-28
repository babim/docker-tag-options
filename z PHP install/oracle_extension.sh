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
	export ORACLE_VERSION=21.1.0.0.0
	if [[ $ORACLE_VERSION == 21.1.0.0.0 ]]; then 
		export ORCL_PATH=21_1
		export ORCL_VERSION=21.1
	fi
	PHP_VERSION=${PHP_VERSION:-false}
	# set path
		export ORACLE_HOME=/opt/oracle/instantclient
		export LD_LIBRARY_PATH="$ORACLE_HOME"
		export PATH="$ORACLE_HOME:$PATH"
}

installoci8() {
	# install oracle client
		create_folder /opt/oracle
		FILETEMP=instantclient-basic-linux.x64-$ORACLE_VERSION.zip
			check_file $FILETEMP && say "file $FILETEMP exist" 	|| $download_save $FILETEMP http://file.matmagoc.com/oracle/$FILETEMP
			unzip_extract $FILETEMP /opt/oracle			&& remove_file $FILETEMP
		FILETEMP=instantclient-sdk-linux.x64-$ORACLE_VERSION.zip
			check_file $FILETEMP && say "file $FILETEMP exist" 	|| $download_save $FILETEMP http://file.matmagoc.com/oracle/$FILETEMP
			unzip_extract $FILETEMP /opt/oracle			&& remove_file $FILETEMP
		FILETEMP=instantclient-sqlplus-linux.x64-$ORACLE_VERSION.zip
			check_file $FILETEMP && say "file $FILETEMP exist" 	|| $download_save $FILETEMP http://file.matmagoc.com/oracle/$FILETEMP
			unzip_extract $FILETEMP /opt/oracle			&& remove_file $FILETEMP
		mv /opt/oracle/instantclient_$ORCL_PATH $ORACLE_HOME
		create_symlink 		$ORACLE_HOME/libclntsh.so.$ORCL_VERSION $ORACLE_HOME/libclntsh.so
		create_symlink 		$ORACLE_HOME/libocci.so.$ORCL_VERSION $ORACLE_HOME/libocci.so
		create_symlink 		$ORACLE_HOME/sqlplus /usr/bin/sqlplnus
		echo $ORACLE_HOME > /etc/ld.so.conf.d/oracle-instantclient.conf
		ldconfig
	# install php extension
		pecl channel-update pecl.php.net

		if [[ "$PHP_VERSION" == "7.0" || "$PHP_VERSION" == "70" || "$PHP_VERSION" == "7.1" || "$PHP_VERSION" == "71" || "$PHP_VERSION" == "7.2" || "$PHP_VERSION" == "72" || "$PHP_VERSION" == "7.3" || "$PHP_VERSION" == "73" || "$PHP_VERSION" == "7.4" || "$PHP_VERSION" == "74" ]];then
			echo "instantclient,$ORACLE_HOME" 			| pecl install oci8-2.2.0

		elif [[ "$PHP_VERSION" == "5.6" || "$PHP_VERSION" == "56" ]]; then
			echo "instantclient,$ORACLE_HOME"  			| pecl install oci8-2.0.12

		elif [[ "$PHP_VERSION" == "8.0" || "$PHP_VERSION" == "80" ]]; then
			echo "instantclient,$ORACLE_HOME"			| pecl install oci8
		fi

		if check_folder /etc/php/; then
			FILETEMP=fpm/conf.d/30-oci8.ini
			for VARIABLE in /etc/php/*; do
				if [ ! -f "$VARIABLE/$FILETEMP" ]; then
					echo "extension = oci8.so" > $VARIABLE/$FILETEMP
				fi
			done
			FILETEMP=cli/conf.d/30-oci8.ini
			for VARIABLE in /etc/php/*; do
				if [ ! -f "$VARIABLE/$FILETEMP" ]; then
					echo "extension = oci8.so" > $VARIABLE/$FILETEMP
				fi
			done
			FILETEMP=apache2/conf.d/30-oci8.ini
			for VARIABLE in /etc/php/*; do
				if [ ! -f "$VARIABLE/$FILETEMP" ]; then
					echo "extension = oci8.so" > $VARIABLE/$FILETEMP
				fi
			done
		fi

	#Set environement variables for cli (The server must be restarted)
		if check_file /etc/environment; then
			echo "LD_LIBRARY_PATH=\"${ORACLE_HOME}\"" >> /etc/environment
			echo "ORACLE_HOME=\"${ORACLE_HOME}\"" >> /etc/environment
		fi

	#Set environement variables for apache.
		if check_file /etc/apache2/envvars; then
			echo "export LD_LIBRARY_PATH=\"${ORACLE_HOME}\"" >> /etc/apache2/envvars
			echo "export ORACLE_HOME=\"${ORACLE_HOME}\"" >> /etc/apache2/envvars
		fi	
}

# install by OS
echo 'Check OS'
if [[ -f /etc/lsb-release ]] || [[ -f /etc/debian_version ]]; then
	# set environment
		setenvironment
		debian_cmd_interface
	# install package depend
		install_package unzip libaio-dev pkg-config libmongoc-1.0-0 libaio1 build-essential
	# install php depend
		has_value ${PHP_VERSION} && install_package php$PHP_VERSION-dev php-pear php-dev || say "not have php"
	# install oracle client
		installoci8	

elif [[ -f /etc/redhat-release ]]; then
	# set environment
		setenvironment
	# install package depend
		install_package unzip php-oci8
	# install oracle client
		# install oracle client
		create_folder /opt/oracle
		FILETEMP=instantclient-basic-linux.x64-$ORACLE_VERSION.zip
			check_file $FILETEMP && say "file $FILETEMP exist" 	|| $download_save $FILETEMP http://file.matmagoc.com/oracle/$FILETEMP
			unzip_extract $FILETEMP /opt/oracle			&& remove_file $FILETEMP
		FILETEMP=instantclient-sdk-linux.x64-$ORACLE_VERSION.zip
			check_file $FILETEMP && say "file $FILETEMP exist" 	|| $download_save $FILETEMP http://file.matmagoc.com/oracle/$FILETEMP
			unzip_extract $FILETEMP /opt/oracle			&& remove_file $FILETEMP
		FILETEMP=instantclient-sqlplus-linux.x64-$ORACLE_VERSION.zip
			check_file $FILETEMP && say "file $FILETEMP exist" 	|| $download_save $FILETEMP http://file.matmagoc.com/oracle/$FILETEMP
			unzip_extract $FILETEMP /opt/oracle			&& remove_file $FILETEMP
		mv /opt/oracle/instantclient_$ORCL_PATH $ORACLE_HOME
		create_symlink 		$ORACLE_HOME/libclntsh.so.$ORCL_VERSION $ORACLE_HOME/libclntsh.so
		create_symlink 		$ORACLE_HOME/libocci.so.$ORCL_VERSION $ORACLE_HOME/libocci.so
		create_symlink 		$ORACLE_HOME/sqlplus /usr/bin/sqlplnus
		echo $ORACLE_HOME > /etc/ld.so.conf.d/oracle-instantclient.conf
		ldconfig	
	#Set environement variables for cli (The server must be restarted)
		if check_file /etc/environment; then
			echo "LD_LIBRARY_PATH=\"${ORACLE_HOME}\"" >> /etc/environment
			echo "ORACLE_HOME=\"${ORACLE_HOME}\"" >> /etc/environment
		fi

# OS - other
else
    say_err "Not support your OS"
    exit 1
fi

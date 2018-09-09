	    export ORACLE_VERSION=12.2.0.1.0
		apt-get install -y --force-yes wget unzip libaio-dev php$PHP_VERSION-dev php-pear pkg-config libbson-1.0 libmongoc-1.0-0 php-dev
		wget --progress=bar:force http://media.matmagoc.com/oracle/instantclient-basic-linux.x64-$ORACLE_VERSION.zip && \
		wget --progress=bar:force http://media.matmagoc.com/oracle/instantclient-sdk-linux.x64-$ORACLE_VERSION.zip && \
		wget --progress=bar:force http://media.matmagoc.com/oracle/instantclient-sqlplus-linux.x64-$ORACLE_VERSION.zip && \
		unzip instantclient-basic-linux.x64-$ORACLE_VERSION.zip -d /usr/local/ && \
		unzip instantclient-sdk-linux.x64-$ORACLE_VERSION.zip -d /usr/local/ && \
		unzip instantclient-sqlplus-linux.x64-$ORACLE_VERSION.zip -d /usr/local/ && \
		ln -s /usr/local/instantclient_12_2 /usr/local/instantclient && \
		ln -s /usr/local/instantclient/libclntsh.so.12.1 /usr/local/instantclient/libclntsh.so && \
		ln -s /usr/local/instantclient/sqlplus /usr/bin/sqlplus && \
		echo 'instantclient,/usr/local/instantclient' | pecl install oci8

		FILETEMP=conf.d/30-oci8.ini
		for VARIABLE in /etc/php/*
		do
		if [ -f "$VARIABLE/$FILETEMP" ]; then
			echo "extension=oci8.so" > $VARIABLE/$FILETEMP
		fi
		done

		rm -f instantclient-basic-linux.x64-$ORACLE_VERSION.zip instantclient-sdk-linux.x64-$ORACLE_VERSION.zip instantclient-sqlplus-linux.x64-$ORACLE_VERSION.zip
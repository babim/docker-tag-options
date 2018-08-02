echo 'Check root'
if [ "x$(id -u)" != 'x0' ]; then
    echo 'Error: this script can only be executed by root'
    exit 1
fi
echo 'Check OS'
if [[ -f /etc/lsb-release ]]; then
# install PHP
	export PHP_VERSION=5.6
	[[ ! -d /etc/apache2 ]] || apt-get install -y --force-yes php$PHP_VERSION libapache2-mod-php$PHP_VERSION && \
	[[ ! -d /etc/nginx ]] || apt-get install -y --force-yes php$PHP_VERSION-fpm && \
    apt-get install -y --force-yes imagemagick curl \
    php$PHP_VERSION-json php$PHP_VERSION-gd php$PHP_VERSION-sqlite php$PHP_VERSION-curl php$PHP_VERSION-ldap php$PHP_VERSION-mysql php$PHP_VERSION-pgsql \
    php$PHP_VERSION-imap php$PHP_VERSION-tidy php$PHP_VERSION-xmlrpc php$PHP_VERSION-zip php$PHP_VERSION-mcrypt php$PHP_VERSION-memcache php$PHP_VERSION-intl \
    php$PHP_VERSION-mbstring imagemagick php$PHP_VERSION-sqlite3 php$PHP_VERSION-sybase php$PHP_VERSION-bcmath php$PHP_VERSION-soap php$PHP_VERSION-xml \
    php$PHP_VERSION-phpdbg php$PHP_VERSION-opcache php$PHP_VERSION-bz2 php$PHP_VERSION-odbc php$PHP_VERSION-interbase php$PHP_VERSION-gmp php$PHP_VERSION-xsl && \
    [[ ! -d /etc/apache2 ]] || a2enmod rewrite headers http2 ssl
# Fix run suck
    [[ -d /run/php ]] || mkdir -p /run/php/
# install composer
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
# fix shortcut bin
    ln -sf /usr/bin/php$PHP_VERSION /etc/alternatives/php
# install option for webapp (owncloud)
	apt-get install -y --force-yes smbclient ffmpeg ghostscript openexr openexr openexr libxml2 gamin
# install oracle client extension
	export ORACLE_VERSION=12.2.0.1.0
	apt-get install -y --force-yes wget unzip libaio-dev php$PHP_VERSION-dev php-pear
    wget http://media.matmagoc.com/oracle/instantclient-basic-linux.x64-$ORACLE_VERSION.zip && \
    wget http://media.matmagoc.com/oracle/instantclient-sdk-linux.x64-$ORACLE_VERSION.zip && \
    wget http://media.matmagoc.com/oracle/instantclient-sqlplus-linux.x64-$ORACLE_VERSION.zip && \
    unzip instantclient-basic-linux.x64-$ORACLE_VERSION.zip -d /usr/local/ && \
    unzip instantclient-sdk-linux.x64-$ORACLE_VERSION.zip -d /usr/local/ && \
    unzip instantclient-sqlplus-linux.x64-$ORACLE_VERSION.zip -d /usr/local/ && \
    ln -s /usr/local/instantclient_12_2 /usr/local/instantclient && \
    ln -s /usr/local/instantclient/libclntsh.so.12.1 /usr/local/instantclient/libclntsh.so && \
    ln -s /usr/local/instantclient/sqlplus /usr/bin/sqlplus && \
    echo 'instantclient,/usr/local/instantclient' | pecl install oci8-2.0.12 && \
    echo "extension=oci8.so" > /etc/php/$PHP_VERSION/apache2/conf.d/30-oci8.ini && \
    echo "extension=oci8.so" > /etc/php/$PHP_VERSION/cli/conf.d/30-oci8.ini && \
    rm -f instantclient-basic-linux.x64-$ORACLE_VERSION.zip instantclient-sdk-linux.x64-$ORACLE_VERSION.zip instantclient-sqlplus-linux.x64-$ORACLE_VERSION.zip
# download entrypoint
	cd / && \
	wget --no-check-certificate https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20PHP%20install/start.sh && \
	chmod 755 start.sh
# prepare etc start
    curl -s https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20PHP%20install/prepare_final.sh | bash
# remove packages
	apt-get purge wget curl -y
else
    echo "Not support your OS"
    exit
fi
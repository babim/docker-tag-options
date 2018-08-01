echo 'Check OS'
if [[ -f /etc/lsb-release ]]; then
	[[ -d /etc/apache2 ]] || apt-get install -y --force-yes php5.6 libapache2-mod-php5.6 && \
	[[ -d /etc/nginx ]] || apt-get install -y --force-yes php5.6-fpm && \
    apt-get install -y --force-yes imagemagick curl \
    php5.6-json php5.6-gd php5.6-sqlite php5.6-curl php5.6-ldap php5.6-mysql php5.6-pgsql \
    php5.6-imap php5.6-tidy php5.6-xmlrpc php5.6-zip php5.6-mcrypt php5.6-memcache php5.6-intl \
    php5.6-mbstring imagemagick php5.6-sqlite3 php5.6-sybase php5.6-bcmath php5.6-soap php5.6-xml \
    php5.6-phpdbg php5.6-opcache php5.6-bz2 php5.6-odbc php5.6-interbase php5.6-gmp php5.6-xsl && \
    [[ -d /etc/apache2 ]] || a2enmod rewrite headers http2 ssl
# install composer
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
# fix shortcut bin
    ln -sf /usr/bin/php5.6 /etc/alternatives/php
# install option for webapp (owncloud)
	apt-get install -y --force-yes smbclient ffmpeg ghostscript openexr openexr openexr libxml2 gamin
# install oracle client extension
	export ORACLE_VERSION=12.2.0.1.0
	apt-get install -y --force-yes wget unzip libaio-dev php5.6-dev php-pear
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
    echo "extension=oci8.so" > /etc/php/5.6/apache2/conf.d/30-oci8.ini && \
    echo "extension=oci8.so" > /etc/php/5.6/cli/conf.d/30-oci8.ini && \
    rm -f instantclient-basic-linux.x64-$ORACLE_VERSION.zip instantclient-sdk-linux.x64-$ORACLE_VERSION.zip instantclient-sqlplus-linux.x64-$ORACLE_VERSION.zip
	apt-get purge wget curl -y
# prepare etc start
    [[ -d /etc-start ]] || rm -rf /etc-start && \
    [[ -d /etc/nginx ]] || mkdir -p /etc-start/nginx && \
    [[ -d /etc/nginx ]] || cp -R /etc/nginx/* /etc-start/nginx && \
    [[ -d /etc/php ]] || mkdir -p /etc-start/php && \
    [[ -d /etc/php ]] || cp -R /etc/php/* /etc-start/php && \
    [[ -d /etc/apache2 ]] || mkdir -p /etc-start/apache2 && \
    [[ -d /etc/apache2 ]] || cp -R /etc/apache2/* /etc-start/apache2 && \
    [[ -d /var/www ]] || mkdir -p /etc-start/www && \
    [[ -d /var/www ]] || cp -R /var/www/* /etc-start/www
else
    echo "Not support your OS"
    exit
fi
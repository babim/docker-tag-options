# prepare etc start
    [[ ! -d /etc-start ]] || rm -rf /etc-start
    [[ ! -d /etc/nginx ]] || mkdir -p /etc-start/nginx
    [[ ! -d /etc/nginx ]] || cp -R /etc/nginx/* /etc-start/nginx
    [[ ! -d /etc/php ]] || mkdir -p /etc-start/php
    [[ ! -d /etc/php ]] || cp -R /etc/php/* /etc-start/php
    [[ ! -d /etc/apache2 ]] || mkdir -p /etc-start/apache2
    [[ ! -d /etc/apache2 ]] || cp -R /etc/apache2/* /etc-start/apache2
    [[ ! -d /var/www ]] || mkdir -p /etc-start/www
    [[ ! -d /var/www ]] || cp -R /var/www/* /etc-start/www
# prepare etc start
    [[ ! -d /etc-start ]] || rm -rf /etc-start
# nginx
    [[ ! -d /etc/nginx ]] || mkdir -p /etc-start/nginx
    [[ ! -d /etc/nginx ]] || cp -R /etc/nginx/* /etc-start/nginx
# php
    [[ ! -d /etc/php ]] || mkdir -p /etc-start/php
    [[ ! -d /etc/php ]] || cp -R /etc/php/* /etc-start/php
# apache
    [[ ! -d /etc/apache2 ]] || mkdir -p /etc-start/apache2
    [[ ! -d /etc/apache2 ]] || cp -R /etc/apache2/* /etc-start/apache2
# www data
    [[ ! -d /var/www ]] || mkdir -p /etc-start/www
    [[ ! -d /var/www ]] || cp -R /var/www/* /etc-start/www
# supervisor
    [[ ! -d /etc/supervisor ]] || mkdir -p /etc-start/supervisor
    [[ ! -d /etc/supervisor ]] || cp -R /etc/supervisor/* /etc-start/supervisor
# litespeed
    [[ ! -d /usr/local/lsws ]] || mkdir -p /etc-start/lsws
    [[ ! -d /usr/local/lsws ]] || cp -R /usr/local/lsws/* /etc-start/lsws
# end
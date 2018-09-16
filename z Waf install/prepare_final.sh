# prepare etc start
    [[ ! -d /etc-start ]] || rm -rf /etc-start

    [[ ! -d /etc/nginx ]] || mkdir -p /etc-start/nginx
    [[ ! -d /etc/nginx ]] || cp -R /etc/nginx/* /etc-start/nginx
    [[ ! -d /etc/supervisor ]] || mkdir -p /etc-start/supervisor
    [[ ! -d /etc/supervisor ]] || cp -R /etc/supervisor/* /etc-start/supervisor

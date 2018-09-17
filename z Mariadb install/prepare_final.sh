# prepare etc start
    [[ ! -d /etc-start ]] || rm -rf /etc-start
    [[ ! -d /etc/mysql ]] || mkdir -p /etc-start/mysql
    [[ ! -d /etc/mysql ]] || cp -R /etc/mysql/* /etc-start/mysql
    [[ ! -d /etc/supervisor ]] || mkdir -p /etc-start/supervisor
    [[ ! -d /etc/supervisor ]] || cp -R /etc/supervisor/* /etc-start/supervisor
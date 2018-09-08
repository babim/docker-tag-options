# prepare etc start
    [[ ! -d /etc-start ]] || rm -rf /etc-start
    [[ ! -d /root ]] || mkdir -p /etc-start/root
    [[ ! -d /root ]] || cp -R /root/* /etc-start/root

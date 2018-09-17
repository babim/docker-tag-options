# prepare etc start
	[[ ! -d /etc-start ]] || rm -rf /etc-start
	[[ ! -d /etc/supervisor ]] || mkdir -p /etc-start/supervisor
	[[ ! -d /etc/supervisor ]] || cp -R /etc/supervisor/* /etc-start/supervisor
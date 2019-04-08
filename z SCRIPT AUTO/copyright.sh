#  ____        _     _
# | __ )  __ _| |__ (_)_ __ ___
# |  _ \ / _` | '_ \| | '_ ` _ \
# | |_) | (_| | |_) | | | | | | |
# |____/ \__,_|_.__/|_|_| |_| |_|

# Copyright
copyright() {
		rm -f /etc/motd
		echo "---" > /etc/motd
		echo "Support by AQ Viet Nam. Contact: info@matmagoc.com" >> /etc/motd
		echo "---" >> /etc/motd
		touch "/(C) AQ.jsc Viet Nam"
}
settimezone() {
		TZ=${TZ:-Asia/Ho_Chi_Minh}
		ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
}
# create by OS
	if [[ -f /etc/redhat-release ]]; then
	## Copyright
		copyright
	## Set UTF
		export LC_ALL=en_US.UTF-8
	# Set timezone to VN
		settimezone
	elif [[ -f /etc/lsb-release ]] || [[ -f /etc/debian_version ]]; then
	## Copyright
		copyright
	## Set UTF
		export TERM="xterm"
		export LANG="C.UTF-8"
		export LC_ALL="C.UTF-8"
		export DEBIAN_FRONTEND="noninteractive"
		apt-get update && apt-get install -y locales nano		
		dpkg-reconfigure locales
    		locale-gen en_US.UTF-8
    		update-locale LANG=en_US.UTF-8 LC_CTYPE=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8
	# Set timezone to VN
		settimezone
	## clean
		apt-get clean
    		apt-get autoclean
		apt-get autoremove -y
		rm -rf /build
		rm -rf /tmp/* /var/tmp/*
		rm -rf /var/lib/apt/lists/*
	elif [[ -f /etc/alpine-release ]]; then
	## Copyright
		copyright
	## Set timezone
		apk add --no-cache tzdata nano
	# Set timezone to VN
		settimezone
	# clean timezone data
		apk del tzdata
	else
	    exit
	fi
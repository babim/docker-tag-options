#  ____        _     _
# | __ )  __ _| |__ (_)_ __ ___
# |  _ \ / _` | '_ \| | '_ ` _ \
# | |_) | (_| | |_) | | | | | | |
# |____/ \__,_|_.__/|_|_| |_| |_|

# Copyright
copyright() {
		rm -f /etc/motd
		echo "---" > /etc/motd
		echo "Support by Duc Anh Babim. Contact: babim@matmagoc.com" >> /etc/motd
		echo "---" >> /etc/motd
		touch "/(C) Babim"
}
# create by OS
	if [[ -f /etc/redhat-release ]]; then
	## Copyright
		copyright
	## Set timezone
		export LC_ALL=en_US.UTF-8
		export TZ=Asia/Ho_Chi_Minh
	elif [[ -f /etc/lsb-release ]] || [[ -f /etc/debian_version ]]; then
	## Copyright
		copyright
	## Set timezone
		export TERM="xterm"
		export LANG="C.UTF-8"
		export LC_ALL="C.UTF-8"
		export TZ=Asia/Ho_Chi_Minh
		export DEBIAN_FRONTEND="noninteractive"
		dpkg-reconfigure locales && \
    		locale-gen en_US.UTF-8 && \
    		update-locale LANG=en_US.UTF-8 LC_CTYPE=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8
	elif [[ -f /etc/alpine-release ]]; then
	## Copyright
		copyright
	## Set timezone
		apk add --no-cache tzdata
		cp /usr/share/zoneinfo/Asia/Ho_Chi_Minh /etc/localtime
		echo "Asia/Ho_Chi_Minh" >  /etc/timezone
		apk del tzdata
	else
	    exit
	fi
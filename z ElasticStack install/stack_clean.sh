export UNINSTALL="wget ca-certificates gnupg openssl"

	if [[ -f /etc/redhat-release ]]; then
		yum remove -y $UNINSTALL
		yum clean all
	elif [[ -f /etc/lsb-release ]] || [[ -f /etc/debian_version ]]; then
		apt-get purge -y $UNINSTALL
		apt-get autoremove -y
		apt-get autoclean
		apt-get clean
	elif [[ -f /etc/alpine-release ]]; then
	   	apk del --purge $UNINSTALL
	else
	    exit
	fi
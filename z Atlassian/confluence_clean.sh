# export UNINSTALL="wget curl"

 	if [[ -f /etc/redhat-release ]]; then
		yum remove -y $UNINSTALL
		yum clean all
 	elif [[ -f /etc/lsb-release ]] || [[ -f /etc/debian_version ]]; then
		apt-get purge -y $UNINSTALL
		apt-get autoremove -y
		apt-get autoclean
		apt-get clean
		rm -rf /build
		rm -rf /tmp/* /var/tmp/*
		rm -rf /var/lib/apt/lists/*
		rm -f /etc/dpkg/dpkg.cfg.d/02apt-speedup
 	elif [[ -f /etc/alpine-release ]]; then
		apk del --purge $UNINSTALL
 	else
 	    echo "not support"
 	fi


if [ -r /etc/os-release ]; then
	echo " detecting OS type : "
	. /etc/os-release
	if [ $ID == "ubuntu" ]; then
		echo "detected OS: $ID - $VERSION_ID"
		if [ `echo "$VERSION_ID" | cut -b-2 ` == "14" ]; then
			echo "deb http://ppa.launchpad.net/alessandro-strada/ppa/ubuntu trusty main" >> /etc/apt/sources.list \
			&& echo "deb-src http://ppa.launchpad.net/alessandro-strada/ppa/ubuntu trusty main" >> /etc/apt/sources.list
		elif [ `echo "$VERSION_ID" | cut -b-2 ` == "12" ]; then
			echo "deb http://ppa.launchpad.net/alessandro-strada/ppa/ubuntu precise main" >> /etc/apt/sources.list \
			&& echo "deb-src http://ppa.launchpad.net/alessandro-strada/ppa/ubuntu precise main" >> /etc/apt/sources.list
		elif [ `echo "$VERSION_ID" | cut -b-2 ` == "16" ]; then
			echo "deb http://ppa.launchpad.net/alessandro-strada/ppa/ubuntu xenial main" >> /etc/apt/sources.list \
			&& echo "deb-src http://ppa.launchpad.net/alessandro-strada/ppa/ubuntu xenial main" >> /etc/apt/sources.list
		elif [ `echo "$VERSION_ID" | cut -b-2 ` == "18" ]; then
			echo "deb http://ppa.launchpad.net/alessandro-strada/ppa/ubuntu bionic main" >> /etc/apt/sources.list \
			&& echo "deb-src http://ppa.launchpad.net/alessandro-strada/ppa/ubuntu bionic main" >> /etc/apt/sources.list
		fi
		&& apt-key adv --keyserver keyserver.ubuntu.com --recv-keys F639B041 \
		&& apt-get update \
		&& apt-get install -yy google-drive-ocamlfuse fuse \
		&& echo "user_allow_other" >> /etc/fuse.conf \
		&& rm /var/log/apt/* /var/log/alternatives.log /var/log/bootstrap.log /var/log/dpkg.log
	else
		echo " This distribution is not currently supported by LST repo "
		echo " If you really have the needs please contact LiteSpeed for support "
	fi
else
	echo " The /etc/os-release file doesn't exist "
	echo " This script couldn't determine which distribution of the repo should be enabled "
fi
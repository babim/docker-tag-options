			echo "deb http://ppa.launchpad.net/alessandro-strada/ppa/ubuntu bionic main" >> /etc/apt/sources.list \
			&& echo "deb-src http://ppa.launchpad.net/alessandro-strada/ppa/ubuntu bionic main" >> /etc/apt/sources.list \
			&& apt-key adv --keyserver keyserver.ubuntu.com --recv-keys F639B041 \
			&& apt-get update \
			&& apt-get install -yy google-drive-ocamlfuse fuse \
			&& echo "user_allow_other" >> /etc/fuse.conf \
			&& rm /var/log/apt/* /var/log/alternatives.log /var/log/bootstrap.log /var/log/dpkg.log
export IPSCAN=${IPSCAN:-3.5.5}
	wget https://github.com/angryip/ipscan/releases/download/$IPSCAN/ipscan_${IPSCAN}_amd64.deb && \
	apt-get install -y --force-yes \
	ca-certificates-java fonts-dejavu-extra java-common libbonobo2-0 \
	libbonobo2-common libgnome-2-0 libgnome2-common libgnomevfs2-0 \
	libgnomevfs2-common liborbit-2-0 openjdk-8-jre openjdk-8-jre-headless && \
	dpkg -i ipscan_${IPSCAN}_amd64.deb && rm -f ipscan_${IPSCAN}_amd64.deb
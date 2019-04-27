#!/bin/bash
#  ____        _     _
# | __ )  __ _| |__ (_)_ __ ___
# |  _ \ / _` | '_ \| | '_ ` _ \
# | |_) | (_| | |_) | | | | | | |
# |____/ \__,_|_.__/|_|_| |_| |_|

say " Install RazorSQL"

# download and install
export RAZORSQL=${RAZORSQL:-7_4_10}
#	wget http://media.matmagoc.com/razorsql_linux_x64.tar.gz
#	tar -xzvpf razorsql${RAZORSQL}_linux_x64.tar.gz -C /opt && rm -f razorsql${RAZORSQL}_linux_x64.tar.gz
	wget https://s3.amazonaws.com/downloads.razorsql.com/downloads/${RAZORSQL}/razorsql${RAZORSQL}_linux_x64.zip
	unzip razorsql${RAZORSQL}_linux_x64.zip -d /opt && rm -f razorsql${RAZORSQL}_linux_x64.zip

# register
	wget http://media.matmagoc.com/razorsqlreg.tar.gz && \
	tar -xzvpf razorsqlreg.tar.gz -C /root && rm -f razorsqlreg.tar.gz
	wget -O /root/Desktop/razorsql.desktop http://media.matmagoc.com/razorsql.desktop && \
	chmod +x /root/Desktop/razorsql.desktop
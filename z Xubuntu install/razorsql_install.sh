			wget http://media.matmagoc.com/razorsql_linux_x64.tar.gz && \
			tar -xzvpf razorsql_linux_x64.tar.gz -C /opt && rm -f razorsql_linux_x64.tar.gz && \
			wget http://media.matmagoc.com/razorsqlreg.tar.gz && \
			tar -xzvpf razorsqlreg.tar.gz -C /root && rm -f razorsqlreg.tar.gz
			wget -O /root/Desktop/razorsql.desktop http://media.matmagoc.com/razorsql.desktop && \
			chmod +x /root/Desktop/razorsql.desktop
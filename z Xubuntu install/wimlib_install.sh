export WIMLIB=${WIMLIB:-1.13.0}
	apt-get install -y libxml2-dev ntfs-3g-dev ntfs-3g libfuse-dev libattr1-dev libssl-dev pkg-config build-essential automake && \
	cd /tmp && wget https://wimlib.net/downloads/wimlib-$WIMLIB.tar.gz && tar xzvpf wimlib* && cd wimlib* && ./configure && make && make install && ldconfig && cd .. && \
	rm -rf /tmp/winlib*
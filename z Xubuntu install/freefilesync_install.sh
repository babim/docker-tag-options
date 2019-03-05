export FREEFILESYNC=${FREEFILESYNC:-10.9}
	wget https://freefilesync.org/download/FreeFileSync_${FREEFILESYNC}_Linux.tar.gz && \
	tar -xzvpf FreeFileSync_${FREEFILESYNC}_Linux.tar.gz -C /opt && rm -f FreeFileSync_${FREEFILESYNC}_Linux.tar.gz
	mkdir -p /root/Desktop
	wget -O /root/Desktop/FreeFileSync.desktop http://media.matmagoc.com/FreeFileSync.desktop && \
	chmod +x /root/Desktop/FreeFileSync.desktop
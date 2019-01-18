export FREEFILESYNC=${FREEFILESYNC:-10.7_Linux}
	wget http://media.matmagoc.com/FreeFileSync_$FREEFILESYNC.tar.gz && \
	tar -xzvpf FreeFileSync_$FREEFILESYNC.tar.gz -C /opt && rm -f FreeFileSync_$FREEFILESYNC.tar.gz
	mkdir -p /root/Desktop
	wget -O /root/Desktop/FreeFileSync.desktop http://media.matmagoc.com/FreeFileSync.desktop && \
	chmod +x /root/Desktop/FreeFileSync.desktop
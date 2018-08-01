FROM babim/apache:alpine

RUN mkdir -p /etc-start/periodic /etc-start/periodic && \
    cp -R /etc/crontabs/* /etc-start/crontabs && cp -R /etc/periodic/* /etc-start/periodic 

ENV FSTYPE nfs4
ENV MOUNT_OPTIONS nfsvers=4
ENV MOUNTPOINT /mnt/nfs-1

RUN apk add --no-cache nfs-utils

COPY mountnfs.sh /mountnfs.sh
COPY runcron.sh /runcron.sh
RUN chmod +x /*.sh
FROM babim/mariadb:10.1.alpine

ENV FSTYPE nfs4
ENV MOUNT_OPTIONS nfsvers=4
ENV MOUNTPOINT /mnt/nfs-1

RUN apk add --no-cache nfs-utils

COPY mountnfs.sh /mountnfs.sh
RUN chmod +x /*.sh
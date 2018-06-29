# docker-tag-options

# Download option
## ubuntu/debian
RUN apt-get update && \
    apt-get install -y wget bash && cd / && wget --no-check-certificate https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20SCRIPT%20AUTO/option.sh && \
    chmod 755 /option.sh && apt-get purge -y wget

## redhat/centos
RUN yum install -y wget bash && cd / && wget --no-check-certificate https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20SCRIPT%20AUTO/option.sh && \
    chmod 755 /option.sh && yum remove -y wget

## alpine linux
RUN apk add --no-cache wget bash && cd / && wget --no-check-certificate https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20SCRIPT%20AUTO/option.sh && \
    chmod 755 /option.sh && apk del wget

# option with entrypoint
if [ -f "/option.sh" ]; then /option.sh; fi

## Environment ssh, cron option
```
SSH=false
CRON=false
NFS=false
SYNOLOGY=false
UPGRADE=false
WWWUSER=www-data
MYSQLUSER=mysql
FULLOPTION=true
```

## NFS option
Writing back to the host:
```
docker run -itd \
    --privileged=true \
    --net=host \
    --name nfs-movies \
    -v /media/nfs-movies:/mnt/nfs-1:shared \
    -e SERVER=192.168.0.9 \
    -e SHARE=movies \
    babim/........
```
```
default:
FSTYPE nfs4
MOUNT_OPTIONS nfsvers=4
MOUNTPOINT /mnt/nfs-1
---
max FSTYPE, MOUNT_OPTIONS, MOUNTPOINT
FSTYPE2
FSTYPE3
FSTYPE4
```
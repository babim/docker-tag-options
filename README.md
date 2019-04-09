# (C) AQ.jsc Viet Nam (https://matmagoc.com)
Run option for docker container (ssh, nfs, update...)

## ubuntu/debian
```
RUN apt-get update && \
    apt-get install -y wget bash && cd / && wget --no-check-certificate https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20SCRIPT%20AUTO/option.sh && \
    chmod 755 /option.sh && apt-get purge -y wget
or
RUN curl -Ls https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20SCRIPT%20AUTO/option.sh -o /option.sh
```
## redhat/centos
```
RUN yum install -y wget bash && cd / && wget --no-check-certificate https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20SCRIPT%20AUTO/option.sh && \
    chmod 755 /option.sh && yum remove -y wget
or
RUN curl -Ls https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20SCRIPT%20AUTO/option.sh -o /option.sh
```
## alpine linux
```
RUN apk add --no-cache wget bash && cd / && wget --no-check-certificate https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20SCRIPT%20AUTO/option.sh && \
    chmod 755 /option.sh && apk del --purge wget
or
RUN curl -Ls https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20SCRIPT%20AUTO/option.sh -o /option.sh
```
# option with entrypoint
`if [ -f "/option.sh" ]; then /option.sh; fi`
```
Set timezone
TZ=Asia/Ho_Chi_Minh
```

## Environment ssh, cron option

#### SSH = SSH service for docker container
#### SSHPASS = password for SSH service
#### CRON = Crontab service for container
#### NFS = NFS client mount for container (need full permission)
#### SYNOLOGY = SYNOLOGY user ID
#### UPGRADE = upgrade OS for container
#### DNS = DNS google, cloudflare for this container
#### FULLOPTION = all option above


```
SSH=false
SSHPASS=root (or you set)

CRON=false
NFS=false
SYNOLOGY=false
UPGRADE=false
WWWUSER=www-data
MYSQLUSER=mysql
FULLOPTION=true
DNS=false
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
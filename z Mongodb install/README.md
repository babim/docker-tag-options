# Install MongoDB
(C) AQ.jsc Viet Nam (https://matmagoc.com)

## install depend
`apt-get install wget bash -y`

## install mariadb
`wget --no-check-certificate -O - https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20Mongodb%20install/mariadb_install.sh | bash`

## Set environment
```
ENV MONGO_MAJOR 10.1 		#version
ENV MONGO_VERSION 4.0.2		#version
ENV OSDEB jessie		#or other OS
```

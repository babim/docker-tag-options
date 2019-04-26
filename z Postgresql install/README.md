# Install PostgreSQL
(C) AQ.jsc Viet Nam (https://matmagoc.com)

## install depend
`apt-get install wget bash -y`

## install
`wget -O - https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20Postgresql%20install/postgresql_install.sh | bash`

## set environment
```
ENV PG_VERSION 9.5 #or 9.2, 9.3, 9.4, 9.6, 10, 11, 12
ENV OSDEB jessie #or other OS
```
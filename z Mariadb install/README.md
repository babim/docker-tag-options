# Install MariaDB
(C) AQ.jsc Viet Nam (https://matmagoc.com)

## install depend
`apt-get install wget bash -y`

## install mariadb
`wget --no-check-certificate -O - https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20Mariadb%20install/mariadb_install.sh | bash`

## Set environment
```
ENV TYPESQL mariadb #or mysql or mysql5 for mysql 5.5
ENV MARIADB_MAJOR 10.1 #version
ENV OSDEB jessie	#or other OS
```

# Install Oracle Database
(C) AQ.jsc Viet Nam (https://matmagoc.com)

## install depend
`apt-get install wget bash -y`

## install oracledatabase
`wget --no-check-certificate -O - https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20OracleDatabase%20install/oracledatabase_install.sh | bash`

## Set environment
```
ENV VERSION 12cr2 #or 12cr1 or 18c
ENV PRODUCT EE #EE = enterprise, SE = Standard
```

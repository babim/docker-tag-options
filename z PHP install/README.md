# Install php
(C) AQ.jsc Viet Nam (https://matmagoc.com)

## install depend
`apt-get install wget bash -y`

## install php repo
`wget -O - https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20PHP%20install/php-repo-ubuntu.sh | bash`

## install php
`wget -O - https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20PHP%20install/php_install.sh | bash`

## Set PHP_VERSION
```
ENV PHP_VERSION 5.6
ENV PHP_VERSION 7.0
ENV PHP_VERSION 7.1
ENV PHP_VERSION 7.2
```

## Set laravel
`ENV LARAVEL true`
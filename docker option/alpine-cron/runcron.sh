#!/bin/sh

# Prepare
if [ -z "`ls /etc/crontabs`" ]; then cp -R /etc-start/crontabs/* /etc/crontabs; fi
if [ -z "`ls /etc/periodic`" ]; then cp -R /etc-start/periodic/* /etc/periodic; fi

# start cron
/usr/sbin/crond -b -L 8

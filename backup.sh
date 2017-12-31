#!/usr/bin/env bash

MYSQL_DESTINATION=${BACKUP_PATH:-/backup}

BACKUP_MYSQL_USER=${DB_USER:-root}

BACKUP_MYSQL_PASSWORD=${DB_PASS:-}

BACKUP_MYSQL_HOST=${BACKUP_HOST:-localhost}

if [[ ${BACKUP_MYSQL_HOST+defined} = defined ]]; then
    if [ ! -d "$MYSQL_DESTINATION" ]; then
        mkdir -p "$MYSQL_DESTINATION"
    fi

    eval "mysqldump --host='$BACKUP_MYSQL_HOST' --user='$BACKUP_MYSQL_USER' --password='$BACKUP_MYSQL_PASSWORD' --all-databases --events --single-transaction > $MYSQL_DESTINATION/$(date +%Y%m%dT%H%MZ%z)-all.sql"

else
    rm -rf "$MYSQL_DESTINATION"
fi
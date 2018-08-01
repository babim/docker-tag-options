#!/bin/sh
set -e

# mount nfs
FSTYPE2=${FSTYPE2:-$FSTYPE}
MOUNT_OPTIONS2=${MOUNT_OPTIONS2:-$MOUNT_OPTIONS}

FSTYPE3=${FSTYPE3:-$FSTYPE}
MOUNT_OPTIONS3=${MOUNT_OPTIONS3:-$MOUNT_OPTIONS}

FSTYPE4=${FSTYPE4:-$FSTYPE}
MOUNT_OPTIONS4=${MOUNT_OPTIONS4:-$MOUNT_OPTIONS}

FSTYPE5=${FSTYPE5:-$FSTYPE}
MOUNT_OPTIONS5=${MOUNT_OPTIONS5:-$MOUNT_OPTIONS}

# run
mkdir -p "$MOUNTPOINT"

rpcbind -f &
mount -t "$FSTYPE" -o "$MOUNT_OPTIONS" "$SERVER:$SHARE" "$MOUNTPOINT"
mount | grep nfs

# run other
if [[ ! -z "${SERVER2}" ]]; then
mkdir -p "$MOUNTPOINT2"
mount -t "$FSTYPE2" -o "$MOUNT_OPTIONS2" "$SERVER2:$SHARE2" "$MOUNTPOINT2"
mount | grep nfs
fi
if [[ ! -z "${SERVER3}" ]]; then
mkdir -p "$MOUNTPOINT3"
mount -t "$FSTYPE3" -o "$MOUNT_OPTIONS3" "$SERVER3:$SHARE3" "$MOUNTPOINT3"
mount | grep nfs
fi
if [[ ! -z "${SERVER4}" ]]; then
mkdir -p "$MOUNTPOINT4"
mount -t "$FSTYPE4" -o "$MOUNT_OPTIONS4" "$SERVER4:$SHARE4" "$MOUNTPOINT4"
mount | grep nfs
fi
if [[ ! -z "${SERVER5}" ]]; then
mkdir -p "$MOUNTPOINT5"
mount -t "$FSTYPE5" -o "$MOUNT_OPTIONS5" "$SERVER5:$SHARE5" "$MOUNTPOINT5"
mount | grep nfs
fi

exec "$@"

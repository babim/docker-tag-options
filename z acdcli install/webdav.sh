#!/bin/sh
#  ____        _     _
# | __ )  __ _| |__ (_)_ __ ___
# |  _ \ / _` | '_ \| | '_ ` _ \
# | |_) | (_| | |_) | | | | | | |
# |____/ \__,_|_.__/|_|_| |_| |_|

# webdav
# Force user and group because lighttpd runs as webdav
USERNAME=${auser}
GROUP=${auser}
WEBDAVPASS=${WEBDAVPASS:-webdav}

# Only allow read access by default
READWRITE=${READWRITE:=false}

# Add user if it does not exist
#if ! id -u "${USERNAME}" >/dev/null 2>&1; then
#	addgroup -g ${USER_GID:=2222} ${GROUP}
#	adduser -G ${GROUP} -D -H -u ${USER_UID:=2222} ${USERNAME}
#fi

chown $USERNAME /var/log/lighttpd

# create config for webdav
if [ ! -f "$CONFIGPATH/lighttpd.conf" ]; then
# create
cat <<EOF>> $CONFIGPATH/lighttpd.conf
server.modules = (
    "mod_access",
    "mod_accesslog",
    "mod_webdav",
    "mod_auth"
)

include "/etc/lighttpd/mime-types.conf"
server.username       = "$USERNAME"
server.groupname      = "$GROUP"

server.document-root  = "$CLOUDPATH"

server.pid-file       = "/run/lighttpd.pid"
server.follow-symlink = "enable"

# No errorlog specification to keep the default (stderr) and make sure lighttpd
# does not try closing/reopening. And redirect all access logs to a pipe. See
# https://redmine.lighttpd.net/issues/2731 for details
accesslog.filename    = "/tmp/lighttpd.log"
#Omitting the following on purpose
#server.errorlog       = "/dev/stderr"

include "$CONFIGPATH/webdav.conf"
EOF
fi

# create config for webdav
if [ ! -f $CONFIGPATH/webdav.conf ]; then
cat <<'EOF'>> $CONFIGPATH/webdav.conf
$HTTP["remoteip"] !~ "WHITELIST" {

  # Require authentication
  $HTTP["host"] =~ "." {
EOF
cat <<EOF>> $CONFIGPATH/webdav.conf
    server.document-root = "$CLOUDPATH"

    webdav.activate = "enable"
    webdav.is-readonly = "disable"
    webdav.sqlite-db-name = "/locks/lighttpd.webdav_lock.db" 

    auth.backend = "htpasswd"
    auth.backend.htpasswd.userfile = "/cache/htpasswd"
    auth.require = ( "" => ( "method" => "basic",
                             "realm" => "webdav",
                             "require" => "valid-user" ) )
  }

}
EOF
cat <<'EOF'>> $CONFIGPATH/webdav.conf
else $HTTP["remoteip"] =~ "WHITELIST" {

  # Whitelisted IP, do not require user authentication
  $HTTP["host"] =~ "." {
EOF
cat <<EOF>> $CONFIGPATH/webdav.conf
    server.document-root = "$CLOUDPATH"

    webdav.activate = "enable"
    webdav.is-readonly = "disable"
    webdav.sqlite-db-name = "/locks/lighttpd.webdav_lock.db" 
  }

}
EOF
fi

# set webdav password
if [ ! -f $CONFIGPATH/htpasswd ]; then
htpasswd -cb $CONFIGPATH/htpasswd $auser $WEBDAVPASS
fi

# Create directory to hold locks
mkdir /locks
chown ${USERNAME}:${GROUP} /locks

# Force the /webdav directory to be owned by webdav/webdav otherwise we won't be
# able to write to it. This is ok if you mount from volumes, perhaps less if you
# mount from the host, so do this conditionally.
OWNERSHIP=${OWNERSHIP:=false}
if [ "$OWNERSHIP" == "true" ]; then
    chown -R $USERNAME $CLOUDPATH
    chgrp -R $USERNAME $CLOUDPATH
fi

# Setup whitelisting addresses. Adresses that are whitelisted will not need to
# enter credentials to access the webdav storage.
if [ -n "$WHITELIST" ]; then
    sed -i "s/WHITELIST/${WHITELIST}/" $CONFIGPATH/webdav.conf
fi

# Reflect the value of READWRITE into the lighttpd configuration
# webdav.is-readonly. Do this at all times, no matters what was in the file (so
# that THIS shell decides upon the R/W status and nothing else.)
if [ "$READWRITE" == "true" ]; then
    sed -i "s/is-readonly = \"\\w*\"/is-readonly = \"disable\"/" $CONFIGPATH/webdav.conf
else
    sed -i "s/is-readonly = \"\\w*\"/is-readonly = \"enable\"/" $CONFIGPATH/webdav.conf
fi

mkfifo -m 600 /tmp/lighttpd.log
cat <> /tmp/lighttpd.log 1>&2 &
chown $USERNAME /tmp/lighttpd.log
lighttpd -f $CONFIGPATH/lighttpd.conf 2>&1

# Hang on a bit while the server starts
sleep 2
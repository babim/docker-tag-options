#!/bin/bash
#  ____        _     _
# | __ )  __ _| |__ (_)_ __ ___
# |  _ \ / _` | '_ \| | '_ ` _ \
# | |_) | (_| | |_) | | | | | | |
# |____/ \__,_|_.__/|_|_| |_| |_|

set -e

# option with entrypoint
if [ -f "/option.sh" ]; then /option.sh; fi

# set environment
SQUID_CACHE_DIR=/var/spool/squid${SQUID_VERSION}
SQUID_LOG_DIR=/var/log/squid${SQUID_VERSION}
SQUID_DIR=/squid
SQUID_CONFIG_DIR=/etc/squid${SQUID_VERSION}
SQUID_USER=${USER:-squid}
SQUID_USERNAME=${USERNAME:-foo}
SQUID_PASSWORD=${PASSWORD:-bar}
    
if [ -z "`ls ${SQUID_DIR}`" ] || [ -z "`ls ${SQUID_CONFIG_DIR}`" ];then
	cp -R ${SQUID_DIR}_start/* ${SQUID_DIR}
fi

create_log_dir() {
	[[ -d ${SQUID_LOG_DIR} ]] || mkdir -p ${SQUID_LOG_DIR}
	chmod -R 755 ${SQUID_LOG_DIR}
	chown -R ${SQUID_USER}:${SQUID_USER} ${SQUID_DIR}/log
	chown -R ${SQUID_USER}:${SQUID_USER} ${SQUID_LOG_DIR}
}

create_cache_dir() {
	[[ -d ${SQUID_CACHE_DIR} ]] || mkdir -p ${SQUID_CACHE_DIR}
	rm -rf ${SQUID_CACHE_DIR}/*
	chown -R ${SQUID_USER}:${SQUID_USER} ${SQUID_DIR}/cache
	chown -R ${SQUID_USER}:${SQUID_USER} ${SQUID_CACHE_DIR}
}

apply_backward_compatibility_fixes() {
	if [[ -f ${SQUID_CONFIG_DIR}/squid.user.conf ]]; then
		rm -rf ${SQUID_CONFIG_DIR}/squid.conf
		ln -sf ${SQUID_CONFIG_DIR}/squid.user.conf ${SQUID_CONFIG_DIR}/squid.conf
	fi
}

create_log_dir
create_cache_dir
apply_backward_compatibility_fixes

#enable public access
if [[ $PUBLIC = 'true' ]]; then
	echo "Change public access"
	sed -i "s|;acl localnet src 10.0.0.0/8|acl localnet src 0.0.0.0/0|i" $SQUID_CONFIG_DIR/squid.conf
elif [[ $PUBLIC = 'false' ]]; then
	echo "Disable public access"
	sed -i "s|;acl localnet src 0.0.0.0/0|acl localnet src 10.0.0.0/8|i" $SQUID_CONFIG_DIR/squid.conf
else
	echo "Not change public access"
fi

# enable authentication
if [[ $AUTH = 'true' ]]; then
	echo "enable authentication"
		sed -i 's/#acl localnet src/##acl localnet src/g' $SQUID_CONFIG_DIR/squid.conf
		sed -i 's/#http_access allow localnet/##http_access allow localnet/g' $SQUID_CONFIG_DIR/squid.conf
	if [[ -f /etc/lsb-release ]] || [[ -f /etc/debian_version ]]; then
		sed -i 's@#\tauth_param basic program /usr/lib/squid3/basic_ncsa_auth /usr/etc/passwd@auth_param basic program /usr/lib/squid3/basic_ncsa_auth /usr/etc/passwd\nacl ncsa_users proxy_auth REQUIRED@' $SQUID_CONFIG_DIR/squid.conf
		sed -i 's@^http_access allow localhost$@\0\nhttp_access allow ncsa_users@' $SQUID_CONFIG_DIR/squid.conf
	elif [[ -f /etc/alpine-release ]]; then
		sed -i 's@^http_access allow localhost$@auth_param basic program /usr/lib/squid/basic_ncsa_auth /usr/etc/passwd\nacl ncsa_users proxy_auth REQUIRED\nhttp_access allow ncsa_users@' $SQUID_CONFIG_DIR/squid.conf
	fi
# default behaviour is to launch squid
	[[ -d "/usr/etc" ]] || mkdir -p /usr/etc
	htpasswd -bc /usr/etc/passwd "${SQUID_USERNAME}" "${SQUID_PASSWORD}"
fi

# allow arguments to be passed to squid
if [[ ${1:0:1} = '-' ]]; then
	EXTRA_ARGS="$@"
	set --
elif [[ ${1} == squid${SQUID_VERSION} || ${1} == $(which squid${SQUID_VERSION}) ]]; then
	EXTRA_ARGS="${@:2}"
	set --
fi

# default behaviour is to launch squid
if [[ -z ${1} ]]; then
	if [[ ! -d ${SQUID_CACHE_DIR}/00 ]]; then
		echo "Initializing cache..."
		$(which squid${SQUID_VERSION}) -N -f ${SQUID_CONFIG_DIR}/squid.conf -z
	fi
		echo "Starting squid..."
		exec $(which squid${SQUID_VERSION}) -f ${SQUID_CONFIG_DIR}/squid.conf -NYCd 1 ${EXTRA_ARGS}
else
	exec "$@"
fi

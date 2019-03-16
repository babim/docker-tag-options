#!/bin/bash
#  ____        _     _
# | __ )  __ _| |__ (_)_ __ ___
# |  _ \ / _` | '_ \| | '_ ` _ \
# | |_) | (_| | |_) | | | | | | |
# |____/ \__,_|_.__/|_|_| |_| |_|


DUPLICATI_CMD='duplicati-cli'
DUPLICATI_DATADIR=/root/.config/Duplicati

# option with entrypoint
if [ -f "/option.sh" ]; then /option.sh; fi

if [ ! "$(ls -l ${DUPLICATI_DATADIR}/*.sqlite 2>/dev/null |wc -l)" -gt "0" ]; then
	echo 'Copying initial configs...'

	for f in /docker-entrypoint-init.d/*; do
		case "$f" in
			*.sqlite)   echo "$0: copying $f"; cp "$f" ${DUPLICATI_DATADIR}/ ;;
			*)        	echo "$0: ignoring $f" ;;
		esac
		echo
	done
fi

if [ -z "$1" ]; then
    if [ ! -n "$DUPLICATI_PASS" ]; then
	exec duplicati-server --webservice-port=8200 --webservice-interface=*
    fi
	exec duplicati-server --webservice-port=8200 --webservice-interface=* --webservice-password=${DUPLICATI_PASS} --webservice-sslcertificatefile=${DUPLICATI_CERT} --webservice-sslcertificatepassword=${DUPLICATI_CERT_PASS}
else
	$DUPLICATI_CMD $@
	if [ "$?" -eq 100 ] && [ -n "$ENABLE_AUTO_REPAIR" ]; then
		echo "Trying to repair local storage."
		$DUPLICATI_CMD $(echo $@ | sed "s/^\w*\s/repair /g" | sed -r 's/[* ]\/[a-zA-Z_].*+//')
		$DUPLICATI_CMD $@
	fi
fi
#!/bin/bash
#  ____        _     _
# | __ )  __ _| |__ (_)_ __ ___
# |  _ \ / _` | '_ \| | '_ ` _ \
# | |_) | (_| | |_) | | | | | | |
# |____/ \__,_|_.__/|_|_| |_| |_|

# need root to run
	require_root

if [[ -f /etc/lsb-release ]] || [[ -f /etc/debian_version ]]; then
		# percona need wget
		install_package lsb-release gnupg wget
		# install percona repo
		FILETEMP=percona-release_0.1-10.${OSDEB}_all.deb
			$download_save $FILETEMP https://repo.percona.com/apt/$FILETEMP
			install_package $FILETEMP
			remove_file $FILETEMP

	# # install depend
	# apt-get install -y --no-install-recommends \
	# apt-transport-https ca-certificates
	# # add repo Percona
	# set -ex; \
	# 	key='430BDF5C56E7C94E848EE60C1C4CBDCDCD2EFD2A'; \
	# 	export GNUPGHOME="$(mktemp -d)"; \
	# 	gpg --no-tty --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
	# 	gpg --export "$key" > /etc/apt/trusted.gpg.d/percona.gpg; \
	# 	command -v gpgconf > /dev/null && gpgconf --kill all || :; \
	# 	rm -rf "$GNUPGHOME"; \
	# 	key='4D1BB29D63D98E422B2113B19334A25F8507EFA5'; \
	# 	export GNUPGHOME="$(mktemp -d)"; \
	# 	gpg --no-tty --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
	# 	gpg --export "$key" >> /etc/apt/trusted.gpg.d/percona.gpg; \
	# 	command -v gpgconf > /dev/null && gpgconf --kill all || :; \
	# 	rm -rf "$GNUPGHOME"; \
	# 	apt-key list > /dev/null
	# # add Percona's repo for xtrabackup (which is useful for Galera)
	# echo "deb https://repo.percona.com/apt $OSDEB main" > /etc/apt/sources.list.d/percona.list \
	# 	&& { \
	# 		echo 'Package: *'; \
	# 		echo 'Pin: release o=Percona Development Team'; \
	# 		echo 'Pin-Priority: 998'; \
	# 	} > /etc/apt/preferences.d/percona

elif [[ -f /etc/redhat-release ]]; then
	# add repo Percona
	install_package http://www.percona.com/downloads/percona-release/percona-release-0.0-1.x86_64.rpm
else
    say_err "Not support your OS"
    exit 1
fi
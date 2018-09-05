	# add repo Mariadb
	set -ex; \
		key='199369E5404BD5FC7D2FE43BCBCB082A1BB943DB'; \
		export GNUPGHOME="$(mktemp -d)"; \
		gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
		gpg --export "$key" > /etc/apt/trusted.gpg.d/mariadb.gpg; \
		rm -rf "$GNUPGHOME"; \
		key='177F4010FE56CA3336300305F1656F24C74CD1D8'; \
		export GNUPGHOME="$(mktemp -d)"; \
		gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
		gpg --export "$key" >> /etc/apt/trusted.gpg.d/mariadb.gpg; \
		rm -rf "$GNUPGHOME"; \
		key='430BDF5C56E7C94E848EE60C1C4CBDCDCD2EFD2A'; \
		export GNUPGHOME="$(mktemp -d)"; \
		gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
		gpg --export "$key" >> /etc/apt/trusted.gpg.d/mariadb.gpg; \
		rm -rf "$GNUPGHOME"; \
		key='4D1BB29D63D98E422B2113B19334A25F8507EFA5'; \
		export GNUPGHOME="$(mktemp -d)"; \
		gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
		gpg --export "$key" >> /etc/apt/trusted.gpg.d/mariadb.gpg; \
		command -v gpgconf > /dev/null && gpgconf --kill all || :; \
		rm -rf "$GNUPGHOME"; \
		apt-key list > /dev/null
	# set version
	#export MARIADB_MAJOR=10.0
		echo "deb http://ftp.osuosl.org/pub/mariadb/repo/$MARIADB_MAJOR/debian $OSDEB main" > /etc/apt/sources.list.d/mariadb.list
if [[ -f /etc/debian_version ]] || [[ -f /etc/lsb-release ]]; then
	MONGO_PACKAGE=${MONGO_PACKAGE:-mongodb-org-unstable}
	MONGO_REPO=${MONGO_REPO:-repo.mongodb.org}

	GPG_KEYS= \
		DFFA3DCF326E302C4787673A01C4E7FAAAB2461C \
		42F3E95A2C4F08279C4960ADD68FA50FEA312927 \
		0C49F3730359A14518585931BC711F9BA15703C6 \
		2930ADAE8CAF5059EE73BB4B58712A2291FA4AD5 \
		9DA31620334BD75D9DCB49F368818C72E52529D4 \
		E162F504A20CDF15827F718D4B7C549A058F8B6B
	set -ex; \
		export GNUPGHOME="$(mktemp -d)"; \
		for key in $GPG_KEYS; do \
			gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
		done; \
		gpg --export $GPG_KEYS > /etc/apt/trusted.gpg.d/mongodb.gpg; \
		command -v gpgconf && gpgconf --kill all || :; \
		rm -r "$GNUPGHOME"; \
		apt-key list

	echo "deb http://$MONGO_REPO/apt/$OSRUN $OSDEB/${MONGO_PACKAGE%-unstable}/$MONGO_MAJOR multiverse" | tee "/etc/apt/sources.list.d/${MONGO_PACKAGE%-unstable}.list"

elif [[ -f /etc/redhat-release ]]; then
	echo "[mongodb-org-$MONGO_MAJOR]" > etc/yum.repos.d/mongodb-org-$MONGO_MAJOR.repo
	echo "name=MongoDB Repository" >> etc/yum.repos.d/mongodb-org-$MONGO_MAJOR.repo
	echo "baseurl=https://repo.mongodb.org/yum/redhat/$releasever/mongodb-org/$MONGO_MAJOR/x86_64/" >> etc/yum.repos.d/mongodb-org-$MONGO_VERSION.repo
	echo "gpgcheck=1" >> etc/yum.repos.d/mongodb-org-$MONGO_MAJOR.repo
	echo "enabled=1" >> etc/yum.repos.d/mongodb-org-$MONGO_MAJOR.repo
	echo "gpgkey=https://www.mongodb.org/static/pgp/server-$MONGO_MAJOR.asc" >> etc/yum.repos.d/mongodb-org-$MONGO_MAJOR.repo

fi
	# add Percona's repo for xtrabackup (which is useful for Galera)
	echo "deb https://repo.percona.com/apt $OSDEB main" > /etc/apt/sources.list.d/percona.list \
		&& { \
			echo 'Package: *'; \
			echo 'Pin: release o=Percona Development Team'; \
			echo 'Pin-Priority: 998'; \
		} > /etc/apt/preferences.d/percona
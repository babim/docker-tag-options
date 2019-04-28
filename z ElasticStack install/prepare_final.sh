#!/bin/bash
#  ____        _     _
# | __ )  __ _| |__ (_)_ __ ___
# |  _ \ / _` | '_ \| | '_ ` _ \
# | |_) | (_| | |_) | | | | | | |
# |____/ \__,_|_.__/|_|_| |_| |_|

# need root to run
	require_root

# prepare etc start
	remove_filefolder /etc-start
	create_folder /etc-start/supervisor
	check_folder /etc/supervisor && dircopy /etc/supervisor/ /etc-start/supervisor/			|| say "no need copy supervisor config"
if has_value $SOFT; then
	create_folder /etc-start/${SOFT}
	check_folder /usr/share/${SOFT}/config && dircopy /usr/share/${SOFT}/config /etc-start/${SOFT}/	|| say "no need copy ${SOFT} config"
fi
#!/bin/bash
#  ____        _     _
# | __ )  __ _| |__ (_)_ __ ___
# |  _ \ / _` | '_ \| | '_ ` _ \
# | |_) | (_| | |_) | | | | | | |
# |____/ \__,_|_.__/|_|_| |_| |_|

say " Prepare data before build complete"

# prepare etc start
	remove_folder /etc-start
	create_folder /etc-start/root
	dircopy /root/ /etc-start/root/

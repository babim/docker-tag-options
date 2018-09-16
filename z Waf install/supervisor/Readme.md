# use

## with linux
/usr/bin/supervisord -nc /etc/supervisor/supervisord.conf

## with docker
CMD ["supervisord", "-nc", "/etc/supervisor/supervisord.conf"]
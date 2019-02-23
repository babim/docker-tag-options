# add gosu for easy step-down from root
GOSU_VERSION=1.11

# install gosu on your OS linux
if [[ -f /etc/lsb-release ]] || [[ -f /etc/debian_version ]]; then
# debian, ubuntu
set -ex; \
	dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')"; \
	wget --no-check-certificate --progress=bar:force -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch"; \
	chmod +x /usr/local/bin/gosu; \
	gosu nobody true
elif [[ -f /etc/redhat-release ]]; then
# redhat, centos
set -ex; \
	yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm; \
	yum -y install dpkg; \
	\
	dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')"; \
	wget --no-check-certificate --progress=bar:force -O /usr/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch"; \
	chmod +x /usr/bin/gosu; \
	gosu nobody true
elif [[ -f /etc/alpine-release ]]; then
# alpine linux
set -ex; \
	apk add --no-cache dpkg; \
	\
	dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')"; \
	wget --no-check-certificate --progress=bar:force -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch"; \
	chmod +x /usr/local/bin/gosu; \
	gosu nobody true
else
	echo "OS not support."
	exit
fi
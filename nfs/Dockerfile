FROM babim/phpbase:7fpm

RUN  apt-get update && apt-get install -y nfs-common

RUN apt-get clean && \
    apt-get autoclean && \
    apt-get autoremove -y && \
    rm -rf /build && \
    rm -rf /tmp/* /var/tmp/* && \
    rm -rf /var/lib/apt/lists/* && \
    rm -f /etc/dpkg/dpkg.cfg.d/02apt-speedup

COPY mountnfs.sh /mountnfs.sh
RUN chmod +x /mountnfs.sh
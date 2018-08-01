FROM babim/apache

RUN yum install -y nfs-utils

RUN yum clean all

COPY mountnfs.sh /mountnfs.sh
RUN chmod +x /mountnfs.sh
FROM babim/apache

RUN yum install -y cronie nfs-utils

RUN yum clean all

COPY runcron.sh /runcron.sh
RUN chmod +x /runcron.sh
COPY mountnfs.sh /mountnfs.sh
RUN chmod +x /mountnfs.sh
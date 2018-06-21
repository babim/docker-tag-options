FROM babim/apache

RUN yum install -y cronie

RUN yum clean all

COPY runcron.sh /runcron.sh
RUN chmod +x /runcron.sh
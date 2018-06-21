FROM babim/apache

RUN yum install -y nfs-utils openssh-server

RUN yum clean all

COPY runcron.sh /runcron.sh
RUN chmod +x /runcron.sh
COPY runssh.sh /runssh.sh
RUN chmod +x /runssh.sh
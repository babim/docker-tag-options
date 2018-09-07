cd /tmp && \
     wget http://media.matmagoc.com/oracle/oracle-instantclient12.2-basic-12.2.0.1.0-1.x86_64.rpm && \
     wget http://media.matmagoc.com/oracle/oracle-instantclient12.2-devel-12.2.0.1.0-1.x86_64.rpm && \
     wget http://media.matmagoc.com/oracle/oracle-instantclient12.2-sqlplus-12.2.0.1.0-1.x86_64.rpm && \
     yum -y install /tmp/oracle-instantclient*.rpm && \
     rm -f /tmp/oracle-instantclient*.rpm && \
     echo /usr/lib/oracle/12.2/client64/lib > /etc/ld.so.conf.d/oracle-instantclient12.2.conf && \
     ldconfig

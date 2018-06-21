FROM babim/apache:alpine

RUN mkdir -p /etc-start/periodic /etc-start/periodic && \
    cp -R /etc/crontabs/* /etc-start/crontabs && cp -R /etc/periodic/* /etc-start/periodic 

COPY runcron.sh /runcron.sh
RUN chmod +x /*.sh
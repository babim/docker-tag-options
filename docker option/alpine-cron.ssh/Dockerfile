FROM babim/apache:alpine

RUN mkdir -p /etc-start/periodic /etc-start/periodic && \
    cp -R /etc/crontabs/* /etc-start/crontabs && cp -R /etc/periodic/* /etc-start/periodic 

COPY runcron.sh /runcron.sh
COPY runssh.sh /runssh.sh
RUN chmod +x /*.sh

# add ssh
RUN apk add --no-cache openssh

#make sure we get fresh keys
RUN rm -rf /etc/ssh/ssh_host_rsa_key /etc/ssh/ssh_host_dsa_key

RUN mkdir /var/run/sshd
# allow root ssh
RUN sed -i -e '/^PermitRootLogin/s/^.*$/PermitRootLogin yes/' /etc/ssh/sshd_config


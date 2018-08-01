FROM babim/apache:alpine
    
# add ssh
RUN apk add --no-cache openssh
# add entrypoint script
COPY runssh.sh /runssh.sh
RUN chmod +x /runssh.sh

#make sure we get fresh keys
RUN rm -rf /etc/ssh/ssh_host_rsa_key /etc/ssh/ssh_host_dsa_key

RUN mkdir /var/run/sshd
# allow root ssh
RUN sed -i -e '/^PermitRootLogin/s/^.*$/PermitRootLogin yes/' /etc/ssh/sshd_config


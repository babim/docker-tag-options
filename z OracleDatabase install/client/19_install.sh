# version
export release=19
export update=9
# install
yum -y install oracle-release-el7 && \
yum -y install oracle-instantclient${release}.${update}-basic oracle-instantclient${release}.${update}-devel oracle-instantclient${release}.${update}-sqlplus && \
rm -rf /var/cache/yum
#echo /usr/lib/oracle/${release}.${update}/client64/lib > /etc/ld.so.conf.d/oracle-instantclient${release}.${update}.conf && \
#ldconfig

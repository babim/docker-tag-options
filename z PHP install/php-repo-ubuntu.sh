echo 'Check OS'
if [[ -f /etc/lsb-release ]]; then
add-apt-repository ppa:ondrej/php -y
else
    echo "Not support your OS"
    exit
fi
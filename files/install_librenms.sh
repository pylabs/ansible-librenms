#!/bin/bash
# https://docs.librenms.org/Installation/Installation-Ubuntu-1804-Nginx/

DB_USER=$1
DB_PASSWORD=$2
SNMPD_COMMUNITY=$3

apt install acl curl composer fping git graphviz imagemagick mariadb-client mariadb-server mtr-tiny nginx-full nmap php7.3-cli php7.3-curl php7.3-fpm php7.3-gd php7.3-json php7.3-mbstring php7.3-mysql php7.3-snmp php7.3-xml php7.3-zip python-memcache python-mysqldb rrdtool snmp snmpd whois -y
useradd librenms -d /srv/www/librenms -M -r
usermod -a -G librenms www-data

if [ ! -e /srv/www ]; then
    mkdir -p /srv/www
fi

cd /srv/www
git clone https://github.com/librenms/librenms.git
cd librenms
git fetch --tags && git checkout $(git describe --tags $(git rev-list --tags --max-count=1))

chown -R librenms:librenms .
chmod 770 .

sudo -u librenms ./scripts/composer_wrapper.php install --no-dev

mysql -u root -e "CREATE DATABASE librenms CHARACTER SET utf8 COLLATE utf8_unicode_ci"
mysql -u root -e "GRANT ALL PRIVILEGES ON librenms.* TO '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASSWORD}'"

systemctl restart mariadb.service

cp snmpd.conf.example /etc/snmp/snmpd.conf
sed -i "s/RANDOMSTRINGGOESHERE\$/${SNMPD_COMMUNITY}/" /etc/snmp/snmpd.conf

curl -o /usr/bin/distro https://raw.githubusercontent.com/librenms/librenms-agent/master/snmp/distro
chmod +x /usr/bin/distro
systemctl restart snmpd.service

chown -R librenms:librenms .
chmod -R ug=rwX ./rrd ./logs ./bootstrap/cache ./storage ./cache
setfacl -d -m g::rwx ./rrd ./logs ./bootstrap/cache/ ./storage/ ./cache
setfacl -R -m g::rwx ./rrd ./logs ./bootstrap/cache/ ./storage/ ./cache

#!/bin/bash
# https://docs.librenms.org/Installation/Installation-Debian-10-Nginx/

DB_USER=$1
DB_PASSWORD=$2
SNMPD_COMMUNITY=$3


apt install acl curl composer fping git graphviz imagemagick mariadb-client mariadb-server mtr-tiny nginx-full nmap php7.3-cli php7.3-curl php7.3-fpm php7.3-gd php7.3-json php7.3-mbstring php7.3-mysql php7.3-snmp php7.3-xml php7.3-zip python-memcache python-mysqldb rrdtool snmp snmpd whois python3-pymysql python3-dotenv python3-redis python3-setuptools


useradd librenms -d /opt/librenms -M -r
usermod -a -G librenms www-data

cd /opt
git clone https://github.com/librenms/librenms.git

cd librenms
git fetch --tags && git checkout $(git describe --tags $(git rev-list --tags --max-count=1))

chown -R librenms:librenms /opt/librenms
chmod 770 /opt/librenms
setfacl -d -m g::rwx /opt/librenms/rrd /opt/librenms/logs /opt/librenms/bootstrap/cache/ /opt/librenms/storage/
setfacl -R -m g::rwx /opt/librenms/rrd /opt/librenms/logs /opt/librenms/bootstrap/cache/ /opt/librenms/storage/

sudo -u librenms ./scripts/composer_wrapper.php install --no-dev

mysql -u root -e "CREATE DATABASE librenms CHARACTER SET utf8 COLLATE utf8_unicode_ci"
mysql -u root -e "CREATE USER '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASSWORD}'"
mysql -u root -e "GRANT ALL PRIVILEGES ON librenms.* TO '${DB_USER}'@'localhost'"

cp /opt/librenms/snmpd.conf.example /etc/snmp/snmpd.conf
chmod 600 /etc/snmp/snmpd.conf
sed -i "s/RANDOMSTRINGGOESHERE\$/${SNMPD_COMMUNITY}/" /etc/snmp/snmpd.conf

curl -o /usr/bin/distro https://raw.githubusercontent.com/librenms/librenms-agent/master/snmp/distro
chmod +x /usr/bin/distro
systemctl restart snmpd

cp /opt/librenms/librenms.nonroot.cron /etc/cron.d/librenms

cp /opt/librenms/misc/librenms.logrotate /etc/logrotate.d/librenms

chown -R librenms:librenms /opt/librenms
setfacl -d -m g::rwx /opt/librenms/rrd /opt/librenms/logs /opt/librenms/bootstrap/cache/ /opt/librenms/storage/
setfacl -R -m g::rwx /opt/librenms/rrd /opt/librenms/logs /opt/librenms/bootstrap/cache/ /opt/librenms/storage/

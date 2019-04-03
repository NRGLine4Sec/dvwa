#!/bin/bash

# This script will install the followings:
# Apache Webserver
# Mysql Server
# PHP
# Damn Vulnerable Web App (DVWA)

IP_ADDR=$(/sbin/ip -o -4 addr list enp0s3 | awk '{print $4}' | cut -d/ -f1)

echo "Installing wget, netcat and unzip"
apt-get install wget unzip -y

echo "Installing PHP"
apt-get install php7.0 php7.0-mysql php-pear php7.0-gd -y

echo "Installing Apache httpd Server"
apt-get install apache2 -y
/etc/init.d/apache2 start
rm /etc/apache2/sites-enabled/000-default*
echo "<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/html/dvwa
</VirtualHost>" >> /etc/apache2/sites-available/dvwa.conf


echo "Installing mysql-client and mysql-server"
apt-get install mysql-client mysql-server -y
systemctl start mysql

read -p "Enter your MySQL root password: " rootpass
read -p "Database name: " dbname
read -p "Database username: " dbuser
read -p "Enter a password for user $dbuser: " userpass
echo "CREATE DATABASE $dbname;" | mysql -u root -p$rootpass
echo "CREATE USER '$dbuser'@'localhost' IDENTIFIED BY '$userpass';" | mysql -u root -p$rootpass
echo "GRANT ALL PRIVILEGES ON $dbname.* TO '$dbuser'@'localhost';" | mysql -u root -p$rootpass
echo "FLUSH PRIVILEGES;" | mysql -u root -p$rootpass
echo "New MySQL database is successfully created"

echo "Installing Damn Vulnerable Web App (DVWA)"
cd /var/www/html
wget https://codeload.github.com/ethicalhack3r/DVWA/zip/master
unzip master
rm -rf master
mkdir /var/www/html/dvwa
mv DVWA-master/* /var/www/html/dvwa/
rm -rf DVWA-master/
cd /var/www/html/dvwa/config
mv config.inc.php.dist config.inc.php
sed -i "s/'p@ssw0rd'/'$userpass'/" config.inc.php
sed -i "s/'root'/'$dbuser'/" config.inc.php
sed -i "s/''/'dvwaPASSWORD'/" config.inc.php
ln -s /etc/apache2/sites-available/dvwa.conf /etc/apache2/sites-enabled/

echo "edit the PHP configuration file for apache servers and set the value of allow_url_include and allow_url_fopen to ON"
sed -i 's/allow_url_include = Off/allow_url_include = On/' /etc/php/7.0/apache2/php.ini
sed -i 's/allow_url_fopen = Off/allow_url_fopen = On/' /etc/php/7.0/apache2/php.ini
systemctl restart apache2

echo "Installation is done"
echo "Open your web browser and go to http://$IP_ADDR/setup.php to continue to configure"
echo "1. Click on Create / Reset Database"
echo "2. Login to DVWA with the user credentials below"
echo "Username: admin"
echo "Password: password"
echo 
echo "For more info:"
echo "http://www.computersecuritystudent.com/SECURITY_TOOLS/DVWA/DVWAv107/lesson1/index.html"


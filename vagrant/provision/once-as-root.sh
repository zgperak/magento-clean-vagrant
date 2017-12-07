#!/usr/bin/env bash

#== Import script args ==

timezone=$(echo "$1")

#== Bash helpers ==

function info {
  echo " "
  echo "--> $1"
  echo " "
}

#== Provision script ==

info "Provision-script user: `whoami`"

info "Allocate swap for MySQL 5.6"
fallocate -l 2048M /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo '/swapfile none swap defaults 0 0' >> /etc/fstab

info "Configure locales"
update-locale LC_ALL="C"
dpkg-reconfigure locales

info "Configure timezone"
echo ${timezone} | tee /etc/timezone
dpkg-reconfigure --frontend noninteractive tzdata

info "Prepare root password for MySQL"
debconf-set-selections <<< "mysql-server-5.6 mysql-server/root_password password \"''\""
debconf-set-selections <<< "mysql-server-5.6 mysql-server/root_password_again password \"''\""
echo "Done!"

info "Update OS software"
apt-get update
apt-get upgrade -y

info "Installing PPA"
sudo apt-get install -y python-software-properties
sudo add-apt-repository -y ppa:ondrej/php
sudo apt-get update -y

info "Install additional software"
apt-get install -y git php5.6-curl php5.6-cli php5.6-intl php5.6-mysqlnd php5.6-gd php5.6-fpm nginx mysql-server-5.6 php5.6-mcrypt

info "Configure MySQL"
sed -i "s/.*bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/my.cnf
echo "Done!"

info "Configure PHP-FPM"
sed -i 's/user = www-data/user = vagrant/g' /etc/php/php5.6/fpm/pool.d/www.conf
sed -i 's/group = www-data/group = vagrant/g' /etc/php/php5.6/fpm/pool.d/www.conf
sed -i 's/owner = www-data/owner = vagrant/g' /etc/php/php5.6/fpm/pool.d/www.conf
echo "Done!"

info "Configure NGINX"
sed -i 's/user www-data/user vagrant/g' /etc/nginx/nginx.conf
echo "Done!"


info "Enabling site configuration"
ln -s /app/vagrant/nginx/app.conf /etc/nginx/sites-enabled/app.conf
echo "Done!"

info "Create database"
mysql -uroot <<< "CREATE DATABASE shop_db"
info "Create user"
mysql -uroot <<< "CREATE USER 'shop_usr'@'localhost' IDENTIFIED BY '12345678';"
info "Grant permission"
mysql -uroot <<< "GRANT ALL PRIVILEGES ON shop_db.* TO 'shop_usr'@'localhost' WITH GRANT OPTION"
#==info "Import database structure"==
#==mysql -uroot shop_db < /app/shop_structure.sql==
#==info "Import database data"==
#==mysql -uroot shop_db < /app/shop_data.sql==
echo "Done!"

info "Install composer"
curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer


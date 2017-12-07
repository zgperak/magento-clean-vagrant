#!/usr/bin/env bash

#== Import script args ==

shop_admin_email=$(echo "$1")

#== Bash helpers ==

function info {
  echo " "
  echo "--> $1"
  echo " "
}

info "Enabling site configuration"
sudo ln -s /app/vagrant/nginx/app.conf /etc/nginx/sites-enabled/app.conf
echo "Done!"

info "Restart web-stack"
sudo php5enmod mcrypt
sudo service php5-fpm restart
sudo service nginx restart
sudo service mysql restart


info "Bootstrap Magento"
cd /app
php -f src/install.php -- --license_agreement_accepted "yes" --locale "hr_HR" --timezone "Europe/Zagreb" --default_currency "HRK" --db_host "localhost" --db_name "shop_db" --db_user "shop_usr" --db_pass "12345678" --db_prefix "" --url "http://www.magento.dev/" --use_rewrites "yes" --use_secure "no" --secure_base_url "" --use_secure_admin "no"  --admin_firstname "Shop" --admin_lastname "Admin" --admin_email ${shop_admin_email} --admin_username "admin" --admin_password "7890zuiop"

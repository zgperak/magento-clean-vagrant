#!/usr/bin/env bash

#== Import script args ==

shop_admin_email=$(echo "$1")

#== Bash helpers ==

function info {
  echo " "
  echo "--> $1"
  echo " "
}

info "Restart web-stack"
php5.6enmod mcrypt
service php5.6-fpm restart
service nginx restart
service mysql restart


info "Bootstrap Magento"
cd /app
php -f ./src/install.php -- --license_agreement_accepted "yes" --locale "hr_HR" --timezone "Europe/Zagreb" --default_currency "HRK" --db_host "localhost" --db_name "shop_db" --db_user "shop_usr" --db_pass "7890zuiop" --db_prefix "" --url "http://www.shop.yii/" --use_rewrites "yes" --use_secure "no" --secure_base_url "" --use_secure_admin "no"  --admin_firstname "Shop" --admin_lastname "Admin" --admin_email ${shop_admin_email} --admin_username "admin" --admin_password "7890zuiop"

#==info "Import data from Luceed"
#==php -f ./src/shell/startProject.php

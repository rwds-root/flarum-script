#!/bin/bash -       
#title         :flaruminstall.sh
#description   :This script is the updated version of flaruminstall.sh which is originally written by Nartamus.
#author		     :rawados - nginx@hotmail.com
#date          :04/15/20
#version       :1.0
#usage		     :sudo bash flaruminstall.sh
#notes         :Tested with Ubuntu 18
#==============================================================================

#Change below to what you'd like
MY_DOMAIN_NAME=20.211.161.168/flarum
MY_EMAIL=mqodri588@gmail.com
DB_NAME=flarum
DB_PSWD=flarum321

SITES_AVAILABLE='/etc/apache2/sites-available/'

clear

echo "***************************************"
echo "*          Flarum Installer           *"
echo "*  Should work on any Ubuntu Distro   *"  
echo "*            By: Nartamus             *"
echo "***************************************"

read -p "Are you sure?(y/n) " -n 1 -r
echo    
if [[ $REPLY =~ ^[Yy]$ ]]
then
    sudo apt-get update
    sudo apt-get install -y software-properties-common
    sudo add-apt-repository --yes ppa:ondrej/php
    sudo apt-get update
    sudo apt-get -y install apache2 mariadb-server mariadb-client
    sudo apt install -y php7.1 libapache2-mod-php7.1 php7.1-common php7.1-mbstring php7.1-xmlrpc php7.1-soap php7.1-gd php7.1-xml php7.1-intl php7.1-mysql php7.1-cli php7.1-mcrypt php7.1-zip php7.1-curl php7.1-dom composer openssl

    sudo mkdir -p /var/www/$MY_DOMAIN_NAME
    cd /var/www/$MY_DOMAIN_NAME
    composer create-project flarum/flarum . --stability=beta

    sudo chown -R www-data:www-data /var/www/$MY_DOMAIN_NAME    

    sudo echo " <VirtualHost *:80>
                    ServerAdmin $MY_EMAIL
                    ServerName $MY_DOMAIN_NAME
                    ServerAlias www.$MY_DOMAIN_NAME
                    DocumentRoot /var/www/$MY_DOMAIN_NAME
                    <Directory /var/www/$MY_DOMAIN_NAME>                    
                        AllowOverride all
                    </Directory>
                    ErrorLog /var/log/apache2/$MY_DOMAIN_NAME-error.log
                    LogLevel error
                    CustomLog /var/log/apache2/$MY_DOMAIN_NAME-access.log combined
		        </VirtualHost>" > $SITES_AVAILABLE$MY_DOMAIN_NAME.conf

    sudo a2ensite $MY_DOMAIN_NAME
    sudo a2enmod rewrite
    sudo a2dissite 000-default.conf
    sudo systemctl restart apache2

    sudo chmod -R 775 /var/www/$MY_DOMAIN_NAME

    sudo mysql -uroot -p$DB_PSWD -e "CREATE DATABASE $DB_NAME"
    sudo mysql -uroot -p$DB_PSWD -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO 'root'@'localhost' IDENTIFIED BY '$DB_PSWD'"
else
    clear
fi

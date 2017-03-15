#!/bin/bash
############################################################
# Let us Setup Apache2 for Ubuntu 16.04 with Php 7 and MySQL
############################################################
# Install Apache2
sudo apt-get update
sudo apt-get install -y --force-yes apache2
# Add PHP 7.0 Repository
#sudo add-apt-repository -y ppa:ondrej/php
# Install PHP 7.0
#sudo apt-get update
#sudo apt-get install -y --force-yes php7.0 libapache2-mod-php7.0 php7.0-fpm
# Copy our virtual host template to sites-enabled overwriting the default site conf
sudo cp travisCI/defaultsite.tpl /etc/apache2/sites-available/000-default.conf
# Copy basic testing files into /var/www
#sudo cp www/info.php /var/www/info.php
sudo cp www/apache.php /var/www/apache.php
# Enable mod rewrite module
sudo a2enmod rewrite
# Set ServerName Globally
sudo cp travisCI/servername.tpl /etc/apache2/conf-available/servername.conf
# Add testing of Apache Bad Bot Blocker
sudo mkdir /etc/apache2/custom.d
cd /etc/apache2/custom.d
sudo wget https://raw.githubusercontent.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/master/custom.d/globalblacklist.conf
sudo wget https://raw.githubusercontent.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/master/custom.d/whitelist-ips.conf
sudo wget https://raw.githubusercontent.com/mitchellkrogza/apache-ultimate-bad-bot-blocker/master/custom.d/whitelist-domains.conf
sudo a2enconf servername
# Restart Apache
sudo service apache2 restart
# Restart PHP-FPM
#sudo service php7.0-fpm restart
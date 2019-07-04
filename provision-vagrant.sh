#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

SITE_URL=$1
DB_DUMP_FILENAME=$2
COMPOSER=/usr/local/bin/composer
BIN_MAGENTO=/vagrant/bin/magento

export COMPOSER_HOME=/home/vagrant/.compos«er

# --------------------
echo 'Removing PHP 7.0..'

sudo apt-get -y install python-software-properties
sudo apt-get -y install software-properties-common
sudo apt-get update
sudo apt-get -y remove php7.0
sudo a2dismod php7.0

# --------------------
echo 'Updating to PHP 7.1..'
sudo apt-get -y install software-properties-common
sudo add-apt-repository ppa:ondrej/php
sudo apt-get update
sudo apt-get -y  install -y php7.1

# --------------------
echo 'Updating PHP extensions..'

sudo apt-get -y install php7.1-curl php7.1-bcmath php7.1-xml php7.1-gd php7.1-intl php7.1-mbstring php7.1-soap php7.1-zip php7.1-mysql
sudo apt-get -y install mcrypt php7.1-mcrypt

# --------------------
echo 'Installing nano..'
sudo apt-get install nano


# --------------------
echo 'Restarting apache2..'
sudo service apache2 restart

# --------------------
echo 'Installing node..'

sudo apt-get install -y nodejs
sudo ln -s /usr/bin/nodejs /usr/bin/node
sudo apt-get install npm


# --------------------
echo 'Deleting default apache web dir and creating symlink mounted vagrant dir from host machine...'

# rm -rf /var/www/html/*

# --------------------
echo 'Replacing contents of default Apache vhost...'

VHOST=$(cat <<EOF
<VirtualHost *:80>
  DocumentRoot "/var/www/html/pub"
  ServerName $SITE_URL
  SetEnv MAGE_IS_DEVELOPER_MODE true
  <Directory "/var/www/html/pub">
    AllowOverride All
  </Directory>
</VirtualHost>
EOF
)

echo "$VHOST" > /etc/apache2/sites-enabled/000-default.conf

a2enmod rewrite
service apache2 restart

# Install n98-magerun2
# --------------------
echo 'Installing n98-magerun2...'
cd /tmp
wget --quiet https://files.magerun.net/n98-magerun2.phar
chmod +x n98-magerun2.phar
sudo mv n98-magerun2.phar /usr/local/bin/n98-magerun

# Install Composer
# --------------------
echo 'Installing Composer...'
wget --quiet -O composer-setup.php https://getcomposer.org/installer
php composer-setup.php --install-dir=/usr/local/bin --filename=composer
rm -Rf composer-setup.php
mv /tmp/composer_auth.json /home/vagrant/.composer/auth.json
cp /tmp/id_rsa.pub /home/vagrant/.ssh/id_rsa.pub
cp /tmp/id_rsa /home/vagrant/.ssh/id_rsa
mkdir /root/.ssh/
mv /tmp/id_rsa.pub /root/.ssh/id_rsa.pub
mv /tmp/id_rsa /root/.ssh/id_rsa
chown vagrant:vagrant /home/vagrant/.ssh/id_rsa.pub
chown vagrant:vagrant /home/vagrant/.ssh/id_rsa
chown root:root /root/.ssh/id_rsa.pub
chown root:root /root/.ssh/id_rsa

# --------------------
echo 'Upgrading Composer...'

$COMPOSER self-update

# --------------------
echo 'Installing dependencies...'

cd /vagrant && $COMPOSER install

# Just in case...
chown vagrant:vagrant -R /home/vagrant/.composer/
chmod +x $BIN_MAGENTO

# --------------------
echo 'Creating Mysql database...'

mysql -u root -proot -e "CREATE DATABASE IF NOT EXISTS magento"
mysql -u root -proot -e "FLUSH PRIVILEGES"

# --------------------
echo 'Enabling Magento Developer mode...'

$BIN_MAGENTO deploy:mode:set developer

# --------------------
echo 'Reindexing Magento...'

$BIN_MAGENTO indexer:reindex

# --------------------
echo '******* HERE YOU GO! You are up & running! (And this will probably be the last happy successful message you will get) - ENJOY! *******'

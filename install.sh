#!/bin/sh
set -e

PRESTASHOP_VERSION="1.7.6.9"
PROJECT_NAME="$(basename "$PWD")"

if [ ! -f composer.lock ]; then
  wget "https://getcomposer.org/composer-stable.phar" -O composer.phar
  chmod -v +x composer.phar
  php -d memory_limit=-1 composer.phar -v req phpguild/docker-web-standard
  php -d memory_limit=-1 composer.phar -v --no-dev --optimize-autoloader install
  rm -v composer.phar
fi

if [ ! -f .gitignore ]; then
  echo "/vendor/" > .gitignore
fi

if [ ! -f .rewrite.conf ]; then
    wget "https://raw.githubusercontent.com/phpguild/docker-prestashop-starter/master/.rewrite.conf.dist" -O .rewrite.conf
fi

if [ ! -f public/composer.lock ]; then
  wget "https://github.com/PrestaShop/PrestaShop/releases/download/${PRESTASHOP_VERSION}/prestashop_${PRESTASHOP_VERSION}.zip" -O "prestashop_${PRESTASHOP_VERSION}.zip"
  unzip "prestashop_${PRESTASHOP_VERSION}.zip" -d prestashop
  unzip "prestashop/prestashop.zip" -d public
  rm -vfr prestashop
  rm -v "prestashop_${PRESTASHOP_VERSION}.zip"
fi

sed -i "s/myapp/${PROJECT_NAME}/g" Makefile
sudo make setup/server
make install

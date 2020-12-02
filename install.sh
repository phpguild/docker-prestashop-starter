#!/usr/bin/env sh

PRESTASHOP_VERSION="1.7.6.9"
PROJECT_NAME="${1}"

if [ -z "${PROJECT_NAME}" ]; then
  echo "Please specify project name (project_name)"
  exit
fi

if [ ! -f composer.lock ]; then
  rm -v README.md
  wget "https://getcomposer.org/composer-stable.phar" -O composer.phar
  chmod -v +x composer.phar
  ./composer.phar install
  rm -v composer.phar
  mv -v .rewrite.conf.dist .rewrite.conf
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

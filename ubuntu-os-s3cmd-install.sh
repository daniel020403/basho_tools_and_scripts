#!/usr/bin/env bash

sudo apt-get -y remove --purge s3cmd
echo ''

sudo apt-get -y install s3cmd
echo ''

echo ''
echo "admin.key" `sudo grep 'admin.key = ' /vagrant/riak-cs.conf`
echo "admin.secret" `sudo grep 'admin.secret = ' /vagrant/riak-cs.conf`
echo "proxy server 192.168.33.10"
echo "proxy port 8080"
echo ''

s3cmd -c ~/.s3cfgfasttrack --configure

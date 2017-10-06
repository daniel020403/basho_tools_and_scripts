#!/usr/bin/env bash

sudo apt-get -y remove --purge s3cmd
echo ''

echo ''
echo "admin.key" `sudo grep 'admin.key = ' /etc/riak-cs/riak-cs.conf`
echo "admin.secret" `sudo grep 'admin.secret = ' /etc/riak-cs/riak-cs.conf`
echo "proxy server <riak-cs-ip>"
echo "proxy port 8080"
echo ''

echo ''
sudo apt-get -y install s3cmd
echo ''

s3cmd -c ~/.s3cfgfasttrack --configure
#!/usr/bin/env bash

sudo apt-get update

sudo apt-get install -y apt-transport-https
sudo apt-get install -y vim
sudo apt-get install -y jq
sudo apt-get install -y s3cmd
sudo apt-get install -y unzip
sudo apt-get install -y git
sudo apt-get install -y sysstat

curl http://s3.amazonaws.com/doc/s3-example-code/s3-curl.zip -o /tmp/s3-curl.zip
sudo unzip -d /usr/local/bin /tmp/s3-curl.zip
sudo chmod -v 755 /usr/local/bin/s3-curl/s3curl.pl
sudo ln -s /usr/local/bin/s3-curl/s3curl.pl /usr/local/bin/s3curl
rm -v /tmp/s3-curl.zip
sudo apt-get install libdigest-hmac-perl
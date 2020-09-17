#!/usr/bin/env bash

RIAK_EE_PACKAGE_SOURCE="/vagrant/riak-ee_2.1.4-1_amd64.deb.2"

RIAK_NAME="riak05"
RIAK_IP="192.168.33.14"
RIAK_PB_PORT="8087"
RIAK_HTTP_PORT="8098"
DISTRIBUTED_COOKIE="cluster00"

sudo riak stop
echo ''

sudo apt-get -y remove --purge riak-ee

cp -v $RIAK_EE_PACKAGE_SOURCE /tmp/riak_ee.deb
chmod +x /tmp/riak_ee.deb
sudo dpkg -i /tmp/riak_ee.deb
sudo apt-get install -f
rm -v /tmp/riak_ee.deb
echo ''

echo "riak" `riak version`
echo ''

sudo sed -i.bak "s/nodename = riak@127.0.0.1/nodename = $RIAK_NAME@$RIAK_IP/" /etc/riak/riak.conf
sudo rm -v /etc/riak/riak.conf.bak
sudo grep nodename /etc/riak/riak.conf
echo ''
sudo sed -i.bak "s/listener.http.internal = 127.0.0.1:8098/listener.http.internal = $RIAK_IP:$RIAK_HTTP_PORT/" /etc/riak/riak.conf
sudo rm -v /etc/riak/riak.conf.bak
sudo grep listener.http.internal /etc/riak/riak.conf
echo ''
sudo sed -i.bak "s/listener.protobuf.internal = 127.0.0.1:8087/listener.protobuf.internal = $RIAK_IP:$RIAK_PB_PORT/" /etc/riak/riak.conf
sudo rm -v /etc/riak/riak.conf.bak
sudo grep listener.protobuf.internal /etc/riak/riak.conf
echo ''
sudo sed -i.bak "s/distributed_cookie = riak/distributed_cookie = $DISTRIBUTED_COOKIE/" /etc/riak/riak.conf
sudo rm -v /etc/riak/riak.conf.bak
sudo grep distributed_cookie /etc/riak/riak.conf
echo ''

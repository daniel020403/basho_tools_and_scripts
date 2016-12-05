#!/usr/bin/env bash

RIAK_EE_PACKAGE_LINK="http://s3.amazonaws.com/private.downloads.basho.com/riak_ee/31f566/2.1.3/ubuntu/trusty/riak-ee_2.1.3-1_amd64.deb"

RIAK_NAME="riak01"
RIAK_IP="192.168.1.80"
RIAK_PB_PORT="8087"
RIAK_HTTP_PORT="8098"
DISTRIBUTED_COOKIE="cluster04"

sudo riak stop
echo ''

sudo apt-get -y remove --purge riak-ee

curl $RIAK_EE_PACKAGE_LINK -o /tmp/riak_ee.deb
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
#!/usr/bin/env bash

RIAK_EE_PACKAGE_USER="daniel-garcia"
RIAK_EE_PACKAGE_HOST="sftp.tiot.jp"
RSYNC_REMOTE_SHELL="ssh -i /home/vagrant/.ssh/daniel_tiot_sftp"
RIAK_EE_PACKAGE_SOURCE="/home/daniel-garcia/sftp-internal/RiakEE/KV/2.1.4/riak-ee_2.1.4-2_amd64.deb"

RIAK_NAME="riak01"
RIAK_IP="192.168.35.10"
RIAK_PB_PORT="8087"
RIAK_HTTP_PORT="8098"
DISTRIBUTED_COOKIE="cluster03"

sudo riak stop
echo ''

sudo apt-get -y remove --purge riak-ee

rsync -azP -e "$RSYNC_REMOTE_SHELL" $RIAK_EE_PACKAGE_USER@$RIAK_EE_PACKAGE_HOST:$RIAK_EE_PACKAGE_SOURCE /tmp/riak_ee.deb
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

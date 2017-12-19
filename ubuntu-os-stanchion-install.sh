#!/usr/bin/env bash

STANCHION_PACKAGE_USER="daniel-garcia"
STANCHION_PACKAGE_HOST="sftp.tiot.jp"
RSYNC_REMOTE_SHELL="ssh -i /home/vagrant/.ssh/daniel_tiot_sftp"
STANCHION_PACKAGE_SOURCE="/home/daniel-garcia/sftp-internal/RiakEE/Stanchion/2.1.1/stanchion_2.1.1-1_amd64.deb"

RIAK_IP="192.168.33.10"
RIAK_PB_PORT="8087"

STANCHION_NAME="stanchion"
STANCHION_IP="192.168.33.10"
STANCHION_LISTENER="8085"

sudo stanchion stop
echo ''

sudo apt-get -y remove --purge stanchion
echo ''

rsync -azP -e "$RSYNC_REMOTE_SHELL" $STANCHION_PACKAGE_USER@$STANCHION_PACKAGE_HOST:$STANCHION_PACKAGE_SOURCE /tmp/stanchion.deb
chmod +x /tmp/stanchion.deb
sudo dpkg -i /tmp/stanchion.deb
sudo apt-get install -f
rm -v /tmp/stanchion.deb
echo ''

sudo sed -i.bak "s/nodename = stanchion@127.0.0.1/nodename = $STANCHION_NAME@$STANCHION_IP/" /etc/stanchion/stanchion.conf
sudo rm -v /etc/stanchion/stanchion.conf.bak
sudo grep nodename /etc/stanchion/stanchion.conf
echo ''
sudo sed -i.bak "s/listener = 127.0.0.1:8085/listener = $STANCHION_IP:$STANCHION_LISTENER/" /etc/stanchion/stanchion.conf
sudo rm -v /etc/stanchion/stanchion.conf.bak
sudo grep listener /etc/stanchion/stanchion.conf
echo ''
sudo sed -i.bak "s/riak_host = 127.0.0.1:8087/riak_host = $RIAK_IP:$RIAK_PB_PORT/" /etc/stanchion/stanchion.conf
sudo rm -v /etc/stanchion/stanchion.conf.bak
sudo grep riak_host /etc/stanchion/stanchion.conf
echo ''

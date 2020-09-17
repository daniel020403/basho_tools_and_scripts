#!/usr/bin/env bash

RIAK_VERSION="2.1.4-1"
RIAK_CS_VERSION="2.1.1-1"
STANCHION_PACKAGE_LINK="http://s3.amazonaws.com/downloads.basho.com/stanchion/2.1/2.1.1/ubuntu/trusty/stanchion_2.1.1-1_amd64.deb"

RIAK_ADVANCED_CONFIG_CS_EBIN="/usr/lib/riak-cs/lib/riak_cs-2.1.1/ebin"

RIAK_NAME="riak"
RIAK_IP="192.168.1.50"
RIAK_PB_PORT="8087"
RIAK_HTTP_PORT="8098"
DISTRIBUTED_COOKIE="cluster01"

RIAK_CS_NAME="riak-cs"
RIAK_CS_IP="192.168.1.50"
RIAK_CS_LISTENER="8080"

STANCHION_NAME="stanchion"
STANCHION_IP="192.168.1.50"
STANCHION_LISTENER="8085"

sudo riak-cs stop
echo ''
sudo stanchion stop
echo ''
sudo riak stop
echo ''

sudo apt-get -y remove --purge riak
echo ''
sudo apt-get -y remove --purge riak-cs
echo ''
sudo apt-get -y remove --purge stanchion
echo ''

curl https://packagecloud.io/gpg.key | sudo apt-key add -
curl -s https://packagecloud.io/install/repositories/basho/riak/script.deb.sh | sudo bash
sudo apt-get install riak=$RIAK_VERSION
echo ''

curl -s https://packagecloud.io/install/repositories/basho/riak-cs/script.deb.sh | sudo bash
sudo apt-get install riak-cs=$RIAK_CS_VERSION
echo ''

curl $STANCHION_PACKAGE_LINK -o /tmp/stanchion.deb
chmod +x /tmp/stanchion.deb
sudo dpkg -i /tmp/stanchion.deb
rm -v /tmp/stanchion.deb
echo ''

echo ''
echo "riak" `riak version`
echo "riak-cs" `riak-cs version`
echo "stanchion" `stanchion version`
echo ''

sudo sed -i.bak 's/storage_backend = bitcask/#storage_backend = bitcask/' /etc/riak/riak.conf
sudo rm -v /etc/riak/riak.conf.bak
echo ''

echo \
"[
   {eleveldb, [
        {total_leveldb_mem_percent, 30}
        ]},
    {riak_kv, [
        %% Other configs
        {add_paths, [\"$RIAK_ADVANCED_CONFIG_CS_EBIN\"]},
        {storage_backend, riak_cs_kv_multi_backend},
        {multi_backend_prefix_list, [{<<\"0b:\">>, be_blocks}]},
        {multi_backend_default, be_default},
        {multi_backend, [
            {be_default, riak_kv_eleveldb_backend, [
                {data_root, \"/var/lib/riak/leveldb\"}
            ]},
            {be_blocks, riak_kv_bitcask_backend, [
                {data_root, \"/var/lib/riak/bitcask\"}
            ]}
        ]}
    ]}
]." | sudo tee /etc/riak/advanced.config
echo ''

echo \
"
buckets.default.allow_mult = true" | sudo tee -a /etc/riak/riak.conf
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
# echo ''

sudo sed -i.bak "s/nodename = riak-cs@127.0.0.1/nodename = $RIAK_CS_NAME@$RIAK_CS_IP/" /etc/riak-cs/riak-cs.conf
sudo rm -v /etc/riak-cs/riak-cs.conf.bak
echo ''
sudo sed -i.bak "s/riak_host = 127.0.0.1:8087/riak_host = $RIAK_IP:$RIAK_PB_PORT/" /etc/riak-cs/riak-cs.conf
sudo rm -v /etc/riak-cs/riak-cs.conf.bak
echo ''
sudo sed -i.bak "s/listener = 127.0.0.1:8080/listener = $RIAK_CS_IP:$RIAK_CS_LISTENER/" /etc/riak-cs/riak-cs.conf
sudo rm -v /etc/riak-cs/riak-cs.conf.bak
echo ''
sudo sed -i.bak "s/stanchion_host = 127.0.0.1:8085/stanchion_host = $STANCHION_IP:$STANCHION_LISTENER/" /etc/riak-cs/riak-cs.conf
sudo rm -v /etc/riak-cs/riak-cs.conf.bak
echo ''

sudo sed -i.bak "s/nodename = stanchion@127.0.0.1/nodename = $STANCHION_NAME@$STANCHION_IP/" /etc/stanchion/stanchion.conf
sudo rm -v /etc/stanchion/stanchion.conf.bak
echo ''
sudo sed -i.bak "s/listener = 127.0.0.1:8085/listener = $STANCHION_IP:$STANCHION_LISTENER/" /etc/stanchion/stanchion.conf
sudo rm -v /etc/stanchion/stanchion.conf.bak
echo ''
sudo sed -i.bak "s/riak_host = 127.0.0.1:8087/riak_host = $RIAK_IP:$RIAK_PB_PORT/" /etc/stanchion/stanchion.conf
sudo rm -v /etc/stanchion/stanchion.conf.bak
echo ''
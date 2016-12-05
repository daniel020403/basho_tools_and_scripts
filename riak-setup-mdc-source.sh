#!/usr/bin/env bash

SOURCE_CLUSTER_NAME="cluster01"
SOURCE_CLUSTERMGR_IP="192.168.1.10"
SOURCE_CLUSTERMGR_PORT="9080"
SINK_CLUSTERMGR_IP="192.168.1.20"
SINK_CLUSTERMGR_PORT="9080"

sudo riak-repl clustername $SOURCE_CLUSTER_NAME
sudo riak-repl clustername
echo ''

sudo sed -i.bak "s/{cluster_mgr, {\"127.0.0.1\", 9080 } }/{cluster_mgr, {\"$IP\", $PORT } }/" /etc/riak/advanced.config
sudo rm -v /etc/riak/advanced.config.bak
sudo grep cluster_mgr /etc/riak/advanced.config
echo ''

sudo riak-repl connect $SINK_CLUSTERMGR_IP:$SINK_CLUSTERMGR_PORT
sudo riak-repl connections
echo ''
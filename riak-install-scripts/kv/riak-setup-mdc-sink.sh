#!/usr/bin/env bash

SINK_CLUSTER_NAME="cluster02"
IP="192.168.1.21"
PORT="9080"

sudo riak-repl clustername $SINK_CLUSTER_NAME
sudo riak-repl clustername
echo ''

sudo sed -i.bak "s/{cluster_mgr, {\"127.0.0.1\", 9080 } }/{cluster_mgr, {\"$IP\", $PORT } }/" /etc/riak/advanced.config
sudo rm -v /etc/riak/advanced.config.bak
sudo grep cluster_mgr /etc/riak/advanced.config
echo ''

sudo riak stop
sudo riak start
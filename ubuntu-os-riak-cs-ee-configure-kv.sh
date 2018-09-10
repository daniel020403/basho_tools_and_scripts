#!/usr/bin/env bash

RIAK_CS_EE_PACKAGE_USER="daniel-garcia"
RIAK_CS_EE_PACKAGE_HOST="sftp.tiot.jp"
RSYNC_REMOTE_SHELL="ssh -i /vagrant/daniel_tiot_sftp"
RIAK_EE_PACKAGE_SOURCE="/home/daniel-garcia/sftp-internal/RiakEE/CS/2.1.1/riak-cs-ee_2.1.1-1_amd64.deb"

RIAK_ADVANCED_CONFIG_CS_EBIN="/usr/lib/riak-cs/lib/riak_cs-2.1.1/ebin"

sudo riak-cs stop
echo ''

sudo apt-get -y remove --purge riak-cs-ee
echo ''

rsync -azP -e "$RSYNC_REMOTE_SHELL" $RIAK_CS_EE_PACKAGE_USER@$RIAK_CS_EE_PACKAGE_HOST:$RIAK_EE_PACKAGE_SOURCE /tmp/riak_cs_ee.deb
chmod +x /tmp/riak_cs_ee.deb
sudo dpkg -i /tmp/riak_cs_ee.deb
sudo apt-get install -fy
rm -v /tmp/riak_cs_ee.deb
echo ''

sudo sed -i.bak 's/storage_backend = bitcask/#storage_backend = bitcask/' /etc/riak/riak.conf
sudo rm -v /etc/riak/riak.conf.bak
echo ''

echo \
"[
 {riak_core,
  [
   %% The cluster manager will listen for connections from remote
   %% clusters on this ip and port. Every node runs one cluster
   %% manager, but only the cluster manager running on the
   %% cluster_leader will service requests. This can change as nodes
   %% enter and leave the cluster.
   {cluster_mgr, {\"127.0.0.1\", 9080 } }
  ]},

 {riak_repl,
  [
   %% Path (relative or absolute) to the working directory for the
   %% replication process
   {data_root, \"/var/lib/riak/riak_repl/\"},

   %% The hard limit of fullsync workers that will be running on the
   %% source side of a cluster across all nodes on that cluster for a
   %% fullsync to a sink cluster. This means if one has configured
   %% fullsync for two different clusters, both with a
   %% max_fssource_cluster of 5, 10 fullsync workers can be in
   %% progress. Only affects nodes on the source cluster on which this
   %% parameter is defined via the configuration file or command line.
   {max_fssource_cluster, 5},

   %% Limits the number of fullsync workers that will be running on
   %% each individual node in a source cluster. This is a hard limit for
   %% all fullsyncs enabled; additional fullsync configurations will not
   %% increase the number of fullsync workers allowed to run on any node.
   %% Only affects nodes on the source cluster on which this parameter is
   %% defined via the configuration file or command line.
   {max_fssource_node, 1},

   %% Limits the number of fullsync workers allowed to run on each
   %% individual node in a sink cluster. This is a hard limit for all
   %% fullsync sources interacting with the sink cluster. Thus, multiple
   %% simultaneous source connections to the sink cluster will have to
   %% share the sink node's number of maximum connections. Only affects
   %% nodes on the sink cluster on which this parameter is defined via
   %% the configuration file or command line.
   {max_fssink_node, 1},

   %% Whether to initiate a fullsync on initial connection from the
   %% sink cluster.
   {fullsync_on_connect, true},

   %% A single integer value representing the duration to wait in
   %% minutes between fullsyncs, or a list of {clustername,
   %% time_in_minutes} pairs for each sink participating in fullsync
   %% replication.
   {fullsync_interval, 30},

   %% The maximum size the realtime replication queue can grow to
   %% before new objects are dropped. Defaults to 100MB. Dropped
   %% objects will need to be replication with a fullsync.
   {rtq_max_bytes, 104857600},

   %% Enable Riak CS proxy_get and block filter.
   {proxy_get, disabled},

   %% A heartbeat message is sent from the source to the sink every
   %% heartbeat_interval. Setting heartbeat_interval to undefined
   %% disables the realtime heartbeat. This feature is only available in
   %% Riak Enterprise 1.3.2+.
   {rt_heartbeat_interval, 15},

   %% If a heartbeat response is not received in rt_heartbeat_timeout
   %% seconds, then the source connection exits and will be
   %% re-established. This feature is only available in Riak
   %% Enterprise 1.3.2+.
   {rt_heartbeat_timeout, 15},

   %% By default, fullsync replication will try to coordinate with
   %% other riak subsystems that may be contending for the same
   %% resources. This will help to prevent system response degradation
   %% under times of heavy load from multiple background tasks. To
   %% disable background coordination, set this parameter to false.
   %% Enterprise 2.0+.
   {fullsync_use_background_manager, true}
  ]},

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

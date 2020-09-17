#!/usr/bin/env bash

cp -v /vagrant/riak-cs-admin-user /tmp/

KEY_ID=`cat /tmp/riak-cs-admin-user | jq '.key_id'`
KEY_ID="${KEY_ID%\"}"
KEY_ID="${KEY_ID#\"}"

KEY_SECRET=`cat /tmp/riak-cs-admin-user | jq '.key_secret'`
KEY_SECRET="${KEY_SECRET%\"}"
KEY_SECRET="${KEY_SECRET#\"}"

sudo sed -i.bak "s/admin.key = admin-key/## admin.key = admin-key/" /etc/riak-cs/riak-cs.conf
sudo rm -v /etc/riak-cs/riak-cs.conf.bak
echo ''
echo \
"
admin.key = $KEY_ID
admin.secret = $KEY_SECRET" | sudo tee -a /etc/riak-cs/riak-cs.conf
echo ''

sudo riak-cs stop
sudo riak-cs start
echo "riak-cs:" `sudo riak-cs ping`
echo ''

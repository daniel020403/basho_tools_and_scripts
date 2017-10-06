#!/usr/bin/env bash

RIAK_IP="192.168.35.10"
RIAK_CS_LISTENER="8080"
ADMIN_NAME="admin"
ADMIN_EMAIL="admin@email.com"

sudo sed -i.bak "s/anonymous_user_creation = off/anonymous_user_creation = on/" /etc/riak-cs/riak-cs.conf
sudo rm -v /etc/riak-cs/riak-cs.conf.bak
echo ''

sudo riak-cs stop
sudo riak-cs start
echo ''

curl -H 'Content-Type: application/json' \
    -XPOST http://$RIAK_IP:$RIAK_CS_LISTENER/riak-cs/user \
    --data "{\"email\":\"$ADMIN_EMAIL\", \"name\":\"$ADMIN_NAME\"}" | sudo tee /tmp/riak-cs-admin-user
echo ''

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

sudo sed -i.bak "s/admin.key = admin-key/## admin.key = admin-key/" /etc/stanchion/stanchion.conf
sudo rm -v /etc/stanchion/stanchion.conf.bak
echo ''
echo \
"
admin.key = $KEY_ID
admin.secret = $KEY_SECRET" | sudo tee -a /etc/stanchion/stanchion.conf
echo ''

sudo stanchion stop
sudo stanchion start

sudo sed -i.bak "s/anonymous_user_creation = on/anonymous_user_creation = off/" /etc/riak-cs/riak-cs.conf
sudo rm -v /etc/riak-cs/riak-cs.conf.bak
echo ''

sudo riak-cs stop
sudo riak-cs start
echo ''
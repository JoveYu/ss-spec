#!/bin/bash


CONF=$1
echo $CONF

rm shadowsocks.json
ln -s $CONF shadowsocks.json
supervisorctl -c supervisor.conf restart ss-local ss-redir ss-tunnel
#sudo sh ss.sh


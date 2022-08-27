#!/bin/bash

### IMPORTANT NOTES ###
### Prerequisite: curl and jq ###

remote_endpont="https://polygon-rpc.com"
local_endpoint="http://127.0.0.1:31271"
telegram_chat_id="CHAT-ID"
telegram_bot="BOT-ID"
alert_message="Polygon Node block difference is: "
block_diff_threshold="10"
check_interval="5"

while true
do
  remote_height=$(($(curl -sX POST -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' $remote_endpont | jq -r .result)))
  local_height=$(($(curl -sX POST -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' $local_endpoint | jq -r .result)))
  re='^[0-9]+$'
  if ! [[ $remote_height =~ $re ]] ; then
     echo "error: remote_height is not a number" >&2; exit 1
  fi

  if ! [[ $local_height =~ $re ]] ; then
     echo "error: local_height not a number" >&2; exit 1
  fi

  echo "Public block height is " $remote_height
  echo "Local block height is " $local_height
  echo "Difference is " `expr $remote_height - $local_height`
  blockdiff=$(expr $remote_height - $local_height)

  if [[ $blockdiff -gt $block_diff_threshold ]]; then
	echo "WARNING: block height is different, sending Alert" \
	&& curl -s -X POST https://api.telegram.org/$telegram_bot/sendMessage -d chat_id=$telegram_chat_id -d text="$(echo -e $alert_message $blockdiff)";
  else
        echo "We are doing fine this time, lets check in "$check_interval "seconds" ;
  fi
  sleep $check_interval
done

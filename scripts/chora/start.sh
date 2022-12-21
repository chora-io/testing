#!/bin/bash

BINARY=chora
NODE_HOME=./data
CHAIN_ID=chora-ica
PORT_GRPC=9090
PORT_GRPC_WEB=9091

echo "Starting $CHAIN_ID in $NODE_HOME..."
echo "Creating log file at $NODE_HOME/$CHAIN_ID.log"
$BINARY start --log_format json --minimum-gas-prices 0uchora --home $NODE_HOME/$CHAIN_ID --pruning=nothing --grpc.address="0.0.0.0:$PORT_GRPC" --grpc-web.address="0.0.0.0:$PORT_GRPC_WEB" > $NODE_HOME/$CHAIN_ID.log 2>&1 &

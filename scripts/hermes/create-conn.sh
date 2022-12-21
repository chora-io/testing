#!/bin/bash

set -e

echo "Initiating connection handshake..."
hermes create connection --a-chain chora-ica --b-chain regen-ica

sleep 2

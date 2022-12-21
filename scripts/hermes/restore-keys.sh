#!/bin/bash

set -e

cp ./scripts/hermes/config.toml ~/.hermes/config.toml

if [ ! -d ~/.hermes/keys/chora-ica ]; then
  hermes keys add --key-name chora-ica --chain chora-ica --mnemonic-file ./scripts/hermes/mnemonic-chora-ica
fi

if [ ! -d ~/.hermes/keys/regen-ica ]; then
  hermes keys add --key-name regen-ica --chain regen-ica --mnemonic-file ./scripts/hermes/mnemonic-regen-ica
fi

sleep 10

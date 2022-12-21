#!/bin/bash

BINARY=regen
NODE_HOME=./data
CHAIN_ID=regen-ica

MNEMONIC_VAL="angry twist harsh drastic left brass behave host shove marriage fall update business leg direct reward object ugly security warm tuna model broccoli choice"
MNEMONIC_TEST_1="vacuum burst ordinary enact leaf rabbit gather lend left chase park action dish danger green jeans lucky dish mesh language collect acquire waste load"
MNEMONIC_TEST_2="open attitude harsh casino rent attitude midnight debris describe spare cancel crisp olive ride elite gallery leaf buffalo sheriff filter rotate path begin soldier"
MNEMONIC_RLY="record gift you once hip style during joke field prize dust unique length more pencil transfer quit train device arrive energy sort steak upset"

PORT_P2P=16657
PORT_RPC=26657
PORT_REST=1317
PORT_ROSETTA=8081

if pgrep -x "$BINARY" >/dev/null; then
    echo "Terminating $BINARY..."
    killall $BINARY
fi

echo "Removing previous data..."
rm -rf $NODE_HOME/$CHAIN_ID &> /dev/null

if ! mkdir -p $NODE_HOME/$CHAIN_ID 2>/dev/null; then
    echo "Failed to create chain folder. Aborting..."
    exit 1
fi

echo "Initializing $CHAIN_ID..."
$BINARY init test --home $NODE_HOME/$CHAIN_ID --chain-id=$CHAIN_ID

echo "Adding genesis accounts..."
echo $MNEMONIC_VAL | $BINARY keys add validator --home $NODE_HOME/$CHAIN_ID --recover --keyring-backend=test
echo $MNEMONIC_TEST_1 | $BINARY keys add test-1 --home $NODE_HOME/$CHAIN_ID --recover --keyring-backend=test
echo $MNEMONIC_TEST_2 | $BINARY keys add test-2 --home $NODE_HOME/$CHAIN_ID --recover --keyring-backend=test
echo $MNEMONIC_RLY | $BINARY keys add relayer --home $NODE_HOME/$CHAIN_ID --recover --keyring-backend=test

$BINARY add-genesis-account $($BINARY --home $NODE_HOME/$CHAIN_ID keys show validator --keyring-backend test -a) 100000000000uregen  --home $NODE_HOME/$CHAIN_ID
$BINARY add-genesis-account $($BINARY --home $NODE_HOME/$CHAIN_ID keys show test-1 --keyring-backend test -a) 100000000000uregen  --home $NODE_HOME/$CHAIN_ID
$BINARY add-genesis-account $($BINARY --home $NODE_HOME/$CHAIN_ID keys show test-2 --keyring-backend test -a) 100000000000uregen  --home $NODE_HOME/$CHAIN_ID
$BINARY add-genesis-account $($BINARY --home $NODE_HOME/$CHAIN_ID keys show relayer --keyring-backend test -a) 100000000000uregen  --home $NODE_HOME/$CHAIN_ID

echo "Creating and collecting gentx..."
$BINARY gentx validator 7000000000uregen --home $NODE_HOME/$CHAIN_ID --chain-id $CHAIN_ID --keyring-backend test

echo "Changing defaults and ports in app.toml and config.toml files..."
sed -i -e 's#"tcp://0.0.0.0:26656"#"tcp://0.0.0.0:'"$PORT_P2P"'"#g' $NODE_HOME/$CHAIN_ID/config/config.toml
sed -i -e 's#"tcp://127.0.0.1:26657"#"tcp://0.0.0.0:'"$PORT_RPC"'"#g' $NODE_HOME/$CHAIN_ID/config/config.toml
sed -i -e 's/timeout_commit = "5s"/timeout_commit = "1s"/g' $NODE_HOME/$CHAIN_ID/config/config.toml
sed -i -e 's/timeout_propose = "3s"/timeout_propose = "1s"/g' $NODE_HOME/$CHAIN_ID/config/config.toml
sed -i -e 's/index_all_keys = false/index_all_keys = true/g' $NODE_HOME/$CHAIN_ID/config/config.toml
sed -i -e 's/enable = false/enable = true/g' $NODE_HOME/$CHAIN_ID/config/app.toml
sed -i -e 's/swagger = false/swagger = true/g' $NODE_HOME/$CHAIN_ID/config/app.toml
sed -i -e 's#"tcp://0.0.0.0:1317"#"tcp://0.0.0.0:'"$PORT_REST"'"#g' $NODE_HOME/$CHAIN_ID/config/app.toml
sed -i -e 's#":8080"#":'"$PORT_ROSETTA"'"#g' $NODE_HOME/$CHAIN_ID/config/app.toml
sed -i -e "s/stake/uregen/g" $NODE_HOME/$CHAIN_ID/config/genesis.json

$BINARY collect-gentxs --home $NODE_HOME/$CHAIN_ID

# Update host chain genesis to allow cosmos.bank.v1beta1.MsgSend and cosmos.staking.v1beta1.MsgDelegate
sed -i -e 's/\"allow_messages\":.*/\"allow_messages\": [\"\/cosmos.bank.v1beta1.MsgSend\",\"\/cosmos.staking.v1beta1.MsgDelegate\"]/g' $NODE_HOME/$CHAIN_ID/config/genesis.json

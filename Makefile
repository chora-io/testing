init-chains:
	@echo "Initializing chora and regen nodes..."
	./scripts/chora/init.sh
	./scripts/regen/init.sh

start-chains: 
	@echo "Starting up a chora and regen nodes..."
	./scripts/chora/start.sh
	./scripts/regen/start.sh

init-hermes: kill-dev init-chains start-chains
	@echo "Initializing relayer..." 
	./scripts/hermes/restore-keys.sh
	./scripts/hermes/create-conn.sh

start-hermes:
	./scripts/hermes/start.sh

kill-dev:
	@echo "Killing chora, regen and removing previous data"
	-@killall chora 2>/dev/null
	-@killall regen 2>/dev/null
	-@rm -rf ./data

PHONY: init-chains start-chains init-hermes start-hermes kill-dev

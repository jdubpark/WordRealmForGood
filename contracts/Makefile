# include .env
ifneq (,$(wildcard ./.env))
    include .env
    export
endif

.PHONY: all test clean deploy-anvil

all: clean remove install update build

# Clean the repo
clean  :; forge clean

# Remove modules
remove :; rm -rf .gitmodules && rm -rf .git/modules/* && rm -rf lib && touch .gitmodules && git add . && git commit -m "modules"

install:
	forge install foundry-rs/forge-std --no-commit
	forge install smartcontractkit/chainlink-brownie-contracts@0.8.0 --no-commit
	forge install openzeppelin/openzeppelin-contracts@v5.0.0 --no-commit

# Update Dependencies
update:; forge update

build:; forge build

test :; forge test 

snapshot :; forge snapshot

slither :; slither ./contracts 

format :; prettier --write contracts/**/*.sol && prettier --write contracts/*.sol

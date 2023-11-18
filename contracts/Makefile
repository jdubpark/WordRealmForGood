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

# Basic slither runs
slither-nft :; slither ./contracts/NFT.sol --solc-remaps "@openzeppelin/=./lib/openzeppelin-contracts/contracts/ @openzeppelin/contracts/=./lib/openzeppelin-contracts/contracts/ @chainlink=./lib/chainlink-brownie-contracts/contracts/src/v0.8/ @chainlink-ccip=./node_modules/@chainlink/contracts-ccip/src/v0.8/"
slither-wordlist :; slither ./contracts/WordList/WordList.sol --solc-remaps "@openzeppelin/=./lib/openzeppelin-contracts/contracts/ @openzeppelin/contracts/=./lib/openzeppelin-contracts/contracts/ @chainlink=./lib/chainlink-brownie-contracts/contracts/src/v0.8/ @chainlink-ccip=./node_modules/@chainlink/contracts-ccip/src/v0.8/"

format :; prettier --write contracts/**/*.sol && prettier --write contracts/*.sol

abi:
	forge inspect contracts/NFT.sol:NFT abi > abi/NFT.json
	forge inspect contracts/SmartTreasury.sol:SmartTreasury abi > abi/SmartTreasury.json

anvil :; anvil --fork-url ${FORK_URL} -m 'test test test test test test test test test test test junk'

deploy-base-goerli-nft:
	@forge script forge-scripts/NFT.s.sol:DeployNFT \
	--optimize \
	--rpc-url $(BASE_TESTNET_RPC) \
	--private-key $(DEPLOYER_PRIVATE_KEY) \
	--broadcast \
	--slow \
	--legacy \
	--with-gas-price 1000000000 \
	-vvvv

deploy-base-goerli-wordlist:
	@forge script forge-scripts/WordList.s.sol:DeployWordList \
	--optimize \
	--rpc-url $(BASE_TESTNET_RPC) \
	--private-key $(DEPLOYER_PRIVATE_KEY) \
	--broadcast \
	--slow \
	--legacy \
	--with-gas-price 1000000000 \
	-vvvv

deploy-eth-sepolia-smarttreasury:
	@forge script forge-scripts/SmartTreasury.s.sol:DeploySmartTreasury \
	--optimize \
	--rpc-url $(ETHEREUM_SEPOLIA_RPC) \
	--private-key $(DEPLOYER_PRIVATE_KEY) \
	--broadcast \
	--slow \
	--legacy \
	--with-gas-price 1200000000 \
	-vvvv

# Note: Run these commands in CLI, for some reason $(cast abi-encde ...) breaks the verify-contract command
verify-base-goerli-nft:
	forge verify-contract \
	--chain base-goerli \
	--etherscan-api-key ${BASESCAN_API_KEY} \
	--watch \
	--constructor-args $(cast abi-encode "constructor(string, string, address, address, address, address)" "WordRealmPublicGood" "WordRPG" "0xA8C0c11bf64AF62CDCA6f93D3769B88BdD7cb93D" "0xD886E2286Fd1073df82462ea1822119600Af80b6" "0x4200000000000000000000000000000000000006" "0xbf9036529123DE264bFA0FC7362fE25B650D4B16") \
	0xAe6b0e9F687a149744B50d8875CC7911dde64410 \
	contracts/NFT.sol:NFT

verify-base-goerli-wordlist:
	forge verify-contract \
	--chain base-goerli \
	--etherscan-api-key ${BASESCAN_API_KEY} \
	--watch \
	0x5ff0e42Ec998aA787561111F112917d7Ae4a64Cb \
	contracts/WordList/WordList.sol:WordList

verify-eth-sepolia-smarttreasury:
	forge verify-contract \
	--chain sepolia \
	--etherscan-api-key ${ETHERSCAN_API_KEY} \
	--watch \
	--constructor-args $(cast abi-encode "constructor(address, bytes32)" "0xb83E47C2bC239B3bf370bc41e1459A34b41238D0" "0x66756e2d657468657265756d2d7365706f6c69612d3100000000000000000000") \
	0x6837Cbcd4ff0bCF18222C4090e0536Db6E4909Cd \
	contracts/SmartTreasury.sol:SmartTreasury

-include .env # Load environment variables from .env file if it exists

build:; forge build # Build the project

deploy-sepolia:
	forge script script/deployfm.s.sol:DeployFundMe --rpc-url $(SEPOLIA_RPC_URL) \
	--private-key $(PRIVATE_KEY) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) \
 	-vvvv # Deploy to Sepolia network verify uploads and match the src code to the deployed bytecode

# you can check the makefile in foundry fund me repo in the chainaccelorg foundry-fundme-23 for more commands
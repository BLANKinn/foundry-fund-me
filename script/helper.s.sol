//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract helper is Script{
// if we are on local anvil,deploy mocks
//otherwise ,grab the existing address rom the live nw

uint8 public constant DECIMALS=8;   
int256 public constant INITIAL_PRICE=2000e8;
//we hate magic no(that we pass as an argument to the mock constructor) so we make them constant
struct NetworkConfig{
    address priceFeed;//ETH/USD price feed address
}

NetworkConfig public activeNw;

constructor(){
    if(block.chainid==11155111){
        activeNw=getsepoConfig();
    }else if(block.chainid==1){
        activeNw=getmainnetConfig();
    }else{
        activeNw=anvilConfig();
    }
}

function getsepoConfig() public pure returns(NetworkConfig memory){//as network config is a struct we need to use memory
    NetworkConfig memory sepoconfi=NetworkConfig({priceFeed:0x694AA1769357215DE4FAC081bf1f309aDC325306});
    return sepoconfi;
}

function getmainnetConfig() public pure returns(NetworkConfig memory){
    NetworkConfig memory mainconfi=NetworkConfig({priceFeed:0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419});
    return mainconfi;
}
function anvilConfig() public  returns(NetworkConfig memory){
  //since we use vm it cant be pure
//activenw is set to address(0) everytime we run the script
  if(activeNw.priceFeed!=address(0)){//if we have already deployed the mock we dont have to deploy again in the same run  
    return activeNw;
  }

  vm.startBroadcast();
 MockV3Aggregator mockpf=new MockV3Aggregator(
    DECIMALS,
    INITIAL_PRICE
 );
 //Chainlink price feeds (like ETH/USD) typically use 8 decimals on testnets and mainnet
 //price=(initial ans/10^dec)=(2000e8/10**8)=2000
  vm.stopBroadcast();
    NetworkConfig memory anvilconfi=NetworkConfig({priceFeed:address(mockpf)});
    return anvilconfi;
}
}


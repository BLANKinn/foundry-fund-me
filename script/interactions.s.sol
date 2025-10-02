// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script,console} from "forge-std/Script.sol";
import {FundMe} from "../src/fundme.sol";
import {DevOpsTools} from "../lib/foundry-devops/src/DevOpsTools.sol";

contract fundfundme is Script {
  uint256 constant SEND_VALUE = 0.01 ether;
    function fundFundme(address mostRecentFundMe) public {
        
        FundMe(payable(mostRecentFundMe)).fund{value: SEND_VALUE}();
       
        console.log("Funding FundMe contract with %s ",SEND_VALUE); 
    }

 function run() external{
    address mostRecentFundMe = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);//it obtains the most recent deployment address of FundMe contract on the current chain from runlatest.json file
    vm.startBroadcast();
    fundfundme(mostRecentFundMe);
    vm.stopBroadcast();
 }
}

contract withdrawfundme is Script {
   
    function withdrawFundme(address mostRecentFundMe) public {
       vm.startBroadcast();
        FundMe(payable(mostRecentFundMe)).withdraw();
         vm.stopBroadcast();
         
    }

 function run() external{
    
    address mostRecentFundMe = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);//it obtains the most recent deployment address of FundMe contract on the current chain from runlatest.json file
    
    withdrawFundme(mostRecentFundMe);
    
 }
}
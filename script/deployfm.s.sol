// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import{Script} from "forge-std/Script.sol";
import {FundMe} from "../src/fundme.sol";
import {helper} from "./helper.s.sol";

contract DeployFundMe is Script{
    function run() external returns(FundMe){
        //before startbroadcast->not a real transaction
        helper help=new helper();
        address ethpf = help.activeNw();
        
//after startbroadcast->a real transaction
        vm.startBroadcast();
        FundMe fundme= new FundMe(ethpf);
        vm.stopBroadcast();
        return fundme;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/fundme.sol";
import {DeployFundMe} from "../../script/deployfm.s.sol";
import {fundfundme, withdrawfundme} from "../../script/interactions.s.sol";

contract interactiontest is Test {
    FundMe fundme;
    uint256 constant STARTING_BALANCE = 10 ether;

    function setUp() external {
        DeployFundMe deployer = new DeployFundMe();
        fundme = deployer.run();
        console.log("FundMe contract initial 2 balance:", address(fundme).balance);
    }

    function testusercanfundandwithdrawinteractions() public {
        fundfundme fk = new fundfundme();
        vm.deal(address(fk), STARTING_BALANCE);
        uint256 fundmestartingbalance = address(fundme).balance;
        fk.fundFundme(address(fundme));

        console.log("FundMe contract balance:", address(fundme).balance);
        uint256 fundmeendingbalance = address(fundme).balance;
        assertEq(address(fundme).balance - fundmestartingbalance, 0.01 ether);
        assertEq(fundme.getfunder(0), address(fk));

        withdrawfundme wf = new withdrawfundme();
        wf.withdrawFundme(address(fundme));

        assert(address(fundme).balance == 0);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/fundme.sol";
import {DeployFundMe} from "../../script/deployfm.s.sol";

contract fundmetest is Test {
    FundMe fundme;
    uint256 constant SEND_VALUE = 0.1 ether;
    address user = makeAddr("user");
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        // fundme = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        // here the test contract is the owner

        DeployFundMe deployer = new DeployFundMe();
        fundme = deployer.run();
        //due to this refactoring we only need to change the script when we change the chain
        //here the broadcaster is the owner
        vm.deal(user, STARTING_BALANCE); // this gives 10 eth to user
    }

    function testmin() public view {
        assertEq(fundme.MINIMUM_USD(), 5e18);
    }

    //us->fundmetest->fundme
    //therefore owner will be fundmetest not us
    //address(this) is fundmetest
    function testowner() public view {
        console.log(address(this));
        console.log(fundme.getowner());
        assertEq(fundme.getowner(), msg.sender); // we use addres(this) when deploying directly in setUp
            //but we use msg.sender when deploying via script after refactoring
            /* You deploy FundMe using DeployFundMe.run() → it uses vm.startBroadcast().
                vm.startBroadcast() makes Foundry deploy the contract as if an public wallet (EOA) is deploying it.
                So:
                fundme.i_owner() = broadcaster (EOA) ✅
                msg.sender = broadcaster ✅*/
    }

    function testversion() public view {
        assertEq(fundme.getVersion(), 4);
    }

    function testfundnotenough() public {
        vm.expectRevert();
        fundme.fund(); //sending 0 eth
            //fundme.fund{value:1e16}(); //sending 0.01 eth
    }

    function testfundupdates() public {
        vm.prank(user); //next tx will be sent by user
        fundme.fund{value: SEND_VALUE}();
        uint256 amountFunded = fundme.getaddressToAmountFunded(user);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testadssfundertoarray() public {
        vm.prank(user);
        fundme.fund{value: SEND_VALUE}();
        address funder = fundme.getfunder(0);
        assertEq(funder, user);
    }

    modifier funded() {
        vm.prank(user);
        fundme.fund{value: SEND_VALUE}();
        _;
    }

    function testonlyownerwithdraw() public funded {
        vm.prank(user);
        vm.expectRevert();
        fundme.withdraw();
    }

    function testwithdrawwithsinglefunder() public funded {
        //arrange
        uint256 startingownerbalance = fundme.getowner().balance;
        uint256 startingfundmebalance = address(fundme).balance;

        //act
        uint256 gasstart = gasleft();
        vm.txGasPrice(GAS_PRICE); // sets the gas price for the next transaction
        vm.prank(fundme.getowner());
        fundme.withdraw();
        uint256 gasend = gasleft();
        uint256 gasused = (gasstart - gasend) * tx.gasprice; //tx.gasprice gives current gas price of the transaction
        console.log(gasused);

        //assert
        uint256 endingownerbalance = fundme.getowner().balance;
        uint256 endingfundmebalance = address(fundme).balance;
        assertEq(endingfundmebalance, 0);
        assertEq(startingownerbalance + startingfundmebalance, endingownerbalance);
    }

    function testwithdrawwithmultiplefunders() public funded {
        //arrange
        uint160 numberofusers = 10;
        uint160 startingindex = 1; // as 0 is already used in funded modifier
        for (uint160 i = startingindex; i < numberofusers; i++) {
            hoax(address(i), STARTING_BALANCE); //gives address(i) 10 eth and next tx will be sent by address(i)
            fundme.fund{value: SEND_VALUE}();
        }
        uint256 startingownerbalance = fundme.getowner().balance;
        uint256 startingfundmebalance = address(fundme).balance;

        //act
        vm.startPrank(fundme.getowner());
        fundme.withdraw();
        vm.stopPrank();

        //assert
        assert(address(fundme).balance == 0);
        assert(startingownerbalance + startingfundmebalance == fundme.getowner().balance);
    }

    function testwithdrawwithmultiplefunderscheaper() public funded {
        //arrange
        uint160 numberofusers = 10;
        uint160 startingindex = 1; // as 0 is already used in funded modifier
        for (uint160 i = startingindex; i < numberofusers; i++) {
            hoax(address(i), STARTING_BALANCE); //gives address(i) 10 eth and next tx will be sent by address(i)
            fundme.fund{value: SEND_VALUE}();
        }
        uint256 startingownerbalance = fundme.getowner().balance;
        uint256 startingfundmebalance = address(fundme).balance;

        //act
        vm.startPrank(fundme.getowner());
        fundme.cheapwithdraw();
        vm.stopPrank();

        //assert
        assert(address(fundme).balance == 0);
        assert(startingownerbalance + startingfundmebalance == fundme.getowner().balance);
    }
}

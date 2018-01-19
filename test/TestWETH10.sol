pragma solidity ^0.4.17;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/WETH10.sol";
import "../contracts/ERC223Compliant.sol";
import "../contracts/ERC223Token.sol";

contract TestWETH10 {

    uint public initialBalance = 10 ether;

    WETH10 weth = WETH10(DeployedAddresses.WETH10());
    ERC223Compliant erc223Receiver = new ERC223Receiver();
    PayableReceiver payableReceiver = new PayableReceiver();

    function testInitialDeposit() {
        uint myInitialWethBalance = weth.balanceOf(this);
        uint myInitialEthBalance = this.balance;

        uint amount = 10000;

        weth.deposit.value(amount)();

        Assert.equal(weth.balanceOf(this), myInitialWethBalance + amount, "This contract should have more WETH now");
        Assert.equal(this.balance, myInitialEthBalance - amount, "This contract should have less ETH now");
    }

    function testERC223Transfer() {
        uint myInitialWethBalance = weth.balanceOf(this);
        uint receiverInitialWethBalance = weth.balanceOf(erc223Receiver);

        bytes memory empty;

        uint amount = 1000;

        if (erc223Receiver.call(0xc0ee0b8a, this, amount, empty)) {
            return false;
        }


        // if (!erc223Receiver.call(bytes4(keccak256("tokenFallback(address,uint256,bytes)")), this, amount, empty)) {
        //     return false;
        // }


       
        weth.transfer(erc223Receiver, amount);

        Assert.equal(weth.balanceOf(this), myInitialWethBalance - amount, "This contract should have less WETH now");
        Assert.equal(weth.balanceOf(erc223Receiver), receiverInitialWethBalance + amount, "The receiver should have more WETH now");
    }
}

contract ERC223Receiver is ERC223Compliant {

    event Received(address indexed from, uint256 value);

    function ERC223Receiver() public {}

    function tokenFallback(address from, uint256 value, bytes /* _data */) public {
        Received(from, value);
    }

}


contract PayableReceiver {
  
    event Received(address indexed from, uint256 value);

    function () payable {
        Received(msg.sender, msg.value);
    }
}


pragma solidity ^0.4.17;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/WETH10.sol";
import "../contracts/ERC223Compliant.sol";
import "../contracts/ERC223Token.sol";

contract TestWETH10 {

    uint public initialBalance = 10 ether;

    WETH10 weth = WETH10(DeployedAddresses.WETH10());
    ERC223Receiver erc223Receiver = new ERC223Receiver();
    PayableReceiver payableReceiver = new PayableReceiver();

    function testInitialDeposit() public {
        uint myInitialWethBalance = weth.balanceOf(this);
        uint myInitialEthBalance = this.balance;

        uint amount = 10000;

        weth.deposit.value(amount)();

        Assert.equal(weth.balanceOf(this), myInitialWethBalance + amount, "This contract should have more WETH now");
        Assert.equal(this.balance, myInitialEthBalance - amount, "This contract should have less ETH now");
    }

    function testERC223Transfer() public {
        bytes memory empty;

        uint myInitialWethBalance = weth.balanceOf(this);
        uint receiverInitialWethBalance = weth.balanceOf(erc223Receiver);
        uint amount = 1000;
       
        weth.transfer(erc223Receiver, amount);

        Assert.equal(weth.balanceOf(this), myInitialWethBalance - amount, "This contract should have less WETH now");
        Assert.equal(weth.balanceOf(erc223Receiver), receiverInitialWethBalance + amount, "The receiver should have more WETH now");
    }


    function testPayableTransfer() {
        bytes memory empty;
        
        uint myInitialWethBalance = weth.balanceOf(this);
        uint receiverInitialWethBalance = weth.balanceOf(payableReceiver);
        uint receiverInitialEthBalance = payableReceiver.balance;
        uint amount = 1000;

        Assert.equal(payableReceiver.call(0xc0ee0b8a, weth.toBytes(this), amount, empty), false, "This should be false");


        weth.transfer(payableReceiver, amount);

        Assert.equal(weth.balanceOf(this), myInitialWethBalance - amount, "This contract should have less WETH now");
        Assert.equal(payableReceiver.balance, receiverInitialEthBalance + amount, "The receiver should have more ETH now");
        Assert.equal(weth.balanceOf(payableReceiver), receiverInitialWethBalance, "The receivers WETH balance should not have changed");
    }
}

contract ERC223Receiver is ERC223Compliant {

    event Received(address indexed from, uint256 value);

    function tokenFallback(address from, uint256 value, bytes /* _data */) public {
        // Received(from, value);
        return;
    }

}


contract PayableReceiver {
  
    event Received(address indexed from, uint256 value);

    function () payable {
        Received(msg.sender, msg.value);
    }
}

contract UnpayableReceiver {

    uint256 x;
  
    event Received(address indexed from, uint256 value);

    // function () payable {
    //     x = msg.value;
    // }
}


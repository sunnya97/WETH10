pragma solidity ^0.4.17;

import "./ERC223Token.sol";
import "./SafeMath.sol";

contract WETH10 is ERC223Token{

    using SafeMath for uint256;

    string public name     = "Wrapped Ether";
    string public symbol   = "WETH";
    uint8  public decimals = 18;

    event  Approval(address indexed src, address indexed guy, uint wad);
    event  Transfer(address indexed src, address indexed dst, uint wad);
    event  Transfer(address indexed src, address indexed dst, uint256 wad, bytes data);
    event  Deposit(address indexed dst, uint wad);
    event  Withdrawal(address indexed src, uint wad);

    mapping (address => uint)                       public  balanceOf;
    mapping (address => mapping (address => uint))  public  allowance;


    function() public payable {
        deposit();
    }

    function deposit() public payable {
        balanceOf[msg.sender] += msg.value;
        Deposit(msg.sender, msg.value);
    }

    function withdraw(uint wad) public {
        require(balanceOf[msg.sender] >= wad);
        balanceOf[msg.sender] -= wad;
        msg.sender.transfer(wad);
        Withdrawal(msg.sender, wad);
    }

    function totalSupply() public view returns (uint) {
        return this.balance;
    }

    function approve(address guy, uint wad) public returns (bool) {
        allowance[msg.sender][guy] = wad;
        Approval(msg.sender, guy, wad);
        return true;
    }
 
    function transferFrom(address src, address dst, uint wad, bytes data) public returns (bool) {
        require(balanceOf[src] >= wad);

        if (src != msg.sender && allowance[src][msg.sender] != uint(-1)) {
            require(allowance[src][msg.sender] >= wad);
            allowance[src][msg.sender] -= wad;
        }

        if(isContract(dst)) {
            // 0xc0ee0b8a == bytes4(keccak256("tokenFallback(address,uint256,bytes)"))
            if (dst.call(0xc0ee0b8a, toBytes(src), wad, data)) {
                balanceOf[src] = balanceOf[src].safeSub(wad);
                balanceOf[dst] = balanceOf[dst].safeAdd(wad);
            } else {
                require(dst.send(wad));
                balanceOf[src] = balanceOf[src].safeSub(wad);
            }
        } else {
            balanceOf[src] = balanceOf[src].safeSub(wad);
            balanceOf[dst] = balanceOf[dst].safeAdd(wad);
        }

        Transfer(src , dst, wad);
        Transfer(src , dst, wad, data);

        return true;
    }

    function transfer(address dst, uint wad) public returns (bool) {
        bytes memory empty;
        return transferFrom(msg.sender, dst, wad, empty);
    }

    function transfer(address dst, uint wad, bytes data) public returns (bool) {
        return transferFrom(msg.sender, dst, wad, data);
    }

    function transferFrom(address src, address dst, uint wad) public returns (bool) {
        bytes memory empty;
        return transferFrom(src, dst, wad, empty);
    }

    //assemble the given address bytecode. If bytecode exists then the _addr is a contract.
    function isContract(address _addr) private view returns (bool is_contract) {
        uint length;
        assembly {
            //retrieve the size of the code on target address, this needs assembly
            length := extcodesize(_addr)
        }
        return (length>0);
    }

    function toBytes(address a) constant returns (bytes32 b){
       assembly {
            let m := mload(0x40)
            mstore(add(m, 20), xor(0x140000000000000000000000000000000000000000, a))
            mstore(0x40, add(m, 52))
            b := m
       }
    }

    // Idk why, but for some reason to getter generation of public variables isn't working.

    function name() public view returns(string) {
        return name;
    }

    function symbol() public view returns(string) {
        return symbol;
    }

    function decimals() public view returns(uint8) {
        return 18;
    }

    function balanceOf(address addr) public view returns (uint256 _balance) {
        return balanceOf[addr];
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return allowance[owner][spender];
    }

}

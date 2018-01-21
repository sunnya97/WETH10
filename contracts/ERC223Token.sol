pragma solidity ^0.4.17;

contract ERC223Token {

    function name() public view returns (string _name);
    function symbol() public view returns (string _symbol);
    function decimals() public view returns (uint8 _decimals);
    function totalSupply() public view returns (uint256 _supply);

    function balanceOf(address who) public view returns (uint256 _balance);

    function transfer(address to, uint value) public returns (bool ok);
    function transfer(address to, uint value, bytes data) public returns (bool ok);

    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function transferFrom(address from, address to, uint256 value, bytes data) public returns (bool);


    function approve(address spender, uint256 value) public returns (bool);
    function allowance(address owner, address spender) public view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Transfer(address indexed from, address indexed to, uint value, bytes indexed data);

    event Approval(address indexed owner, address indexed spender, uint256 value);

}

pragma solidity ^0.4.17;

contract ERC223Compliant {
  function tokenFallback(address _from, uint _value, bytes _data) public;
}

pragma solidity ^0.4.17;

interface ERC223Compliant {
  function tokenFallback(address _from, uint _value, bytes _data) public;
}

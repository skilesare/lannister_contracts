pragma solidity ^0.4.15;


contract iControl {

  mapping(bytes4 => bool) public ownerForbidden;
  mapping(bytes4 => bool) public trusteeForbidden;

  function canStart(address _container, address _owner, address _trustee) constant returns(bool);

}
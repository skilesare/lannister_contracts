pragma solidity ^0.4.15;

import "./iControl.sol";
import "./iENS.sol";
import "./PromiseContainer.sol";


contract ControllerERC20Freeze is iControl {

  mapping(address => bytes32) public node;

  function ControllerERC20Freeze(){
    ownerForbidden[bytes4(keccak256("setOwner(bytes32, owner)"))];
  }

  function setNode(address _container, bytes32 _node) returns (bool){
    assert(msg.sender == PromiseContainer(_container).trustee());
    node[_container] = _node;
  }

  function canStart(address _container, address _owner, address _trustee) constant returns(bool){
    address ENS = 0x0;
    assert(iENS(address(ENS)).owner(node[_container]) == _container);
    return true;
  }

}

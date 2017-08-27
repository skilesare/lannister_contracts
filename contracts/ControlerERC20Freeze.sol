pragma solidity ^0.4.15;

import "./iControl.sol";
import "./ERC20.sol";
import "./PromiseContainer.sol";

contract ControllerERC20Freeze.sol is iControl {

  mapping(address => uint) public collateralAmount;
  mapping(address => address) public token;


  function ControllerERC20Freeze(){
    ownerForbidden[bytes4(keccak256("transfer(address, uint)"))];
    ownerForbidden[bytes4(keccak256("approve(address, uint)"))];
    trusteeForbidden[bytes4(keccak256("transfer(address, uint)"))];
    trusteeForbidden[bytes4(keccak256("approve(address, uint)"))];
  }

  function setCollateral(address _container, address _token,uint _amount) returns (bool){
    assert(msg.sender == PromiseContainer(_container).trustee());
    collateralAmount[_container] = _amount;
    token[_container] = _token;
  }

  function canStart(address _container, address _owner, address _trustee) constant returns(bool){
    assert(ERC20(token[_container]).balanceOf(_container) > (collateralAmount[_container]));
    return true;
  }

}
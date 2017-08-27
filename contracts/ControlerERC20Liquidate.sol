pragma solidity ^0.4.15;

import "./iControl.sol";
import "./PromiseContainer.sol";
import "./ERC20.sol";


contract ControllerERC20Liquidate is iControl {




  mapping(address => uint) public collateralAmount;
  mapping(address => address) public token;

  function ControllerERC20Liquidate(){


    ownerForbidden[bytes4(keccak256("transfer(address, uint)"))] = true;
    ownerForbidden[bytes4(keccak256("approve(address, uint)"))] = true;
  }

  function setCollateral(address _container, address _token, uint _amount) returns (bool){
    assert(msg.sender == PromiseContainer(_container).trustee() );
    collateralAmount[_container] = _amount;
    token[_container] = _token;
  }

  function canStart(address _container, address _owner, address _trustee) constant returns(bool){
    assert(ERC20(token[_container]).balanceOf(_container) > (collateralAmount[_container]));
    return true;
  }

}
pragma solidity ^0.4.15;

import "./iPromise.sol";
import "./iControl.sol";


contract PromiseContainer {

  address public controlContract;
  address public promiseContract;
  address public assetContract;
  address public owner;
  address public trustee;
  bool public delinquent;


  modifier isDelinquent(){
      require(delinquent == true);
      _;
    }

    modifier onlyOwnerOrTrustee(){
      require(msg.sender == owner || msg.sender == trustee);
      _;
    }

    modifier onlyOwner(){
      require(msg.sender == owner || msg.sender == trustee);
      _;
    }

  function PromiseContainer(address _trustee, address _assetContract, address _promiseContract, address _controlContract){
    owner = msg.sender;
    trustee = _trustee;
    promiseContract = _promiseContract;
    controlContract = _controlContract;
    assetContract = _assetContract;
  }

  function defaultContract(){
    if(iPromise(promiseContract).delinquent() == true){
      delinquent = true;
    }
  }

  function restoreContract(){
    if(iPromise(promiseContract).delinquent() == false){
      delinquent = false;
    }
  }

  function startLien() onlyOwner {
    assert(trustee != 0);
    assert(owner != 0);
    assert(promiseContract != 0);
    assert(controlContract != 0);
    assert(iControl(controlContract).canStart(address(this), owner, trustee) == true);


    iPromise(promiseContract).startLien();
  }



  function executeFunction(uint value, bytes4 sig, bytes data) payable onlyOwnerOrTrustee returns(bool){

    assert(sig[0] == data[0]);
    assert(sig[1] == data[1]);
    assert(sig[2] == data[2]);
    assert(sig[3] == data[3]);

    if(delinquent == true){
      assert(msg.sender == trustee);
      assert(iControl(controlContract).trusteeForbidden(sig) != true);
    }
    else {
      assert(msg.sender == owner);
      if(iPromise(promiseContract).lienOn()){
        assert(iControl(controlContract).ownerForbidden(sig) != true);
      }
    }

    bool result = assetContract.call.value(value)(data);

    assert(result != false);
    return true;

  }

}
pragma solidity ^0.4.15;

import "./iPromise.sol";
import "./ERC20.sol";
import "./SafeMath.sol";


contract PromiseEthLoan is iPromise {
    using SafeMath for uint256;
  uint public terms;
  uint public rate;
  uint public periodLength;
  uint public paidBack;
  uint public contractStart;
  uint public currentTerm;
  uint public amount;
  uint public collateralAmount;

  bool public started;
  address public creditor;
  address public debtor;
  address public container;

  modifier isDelinquent(){
      require(delinquent() == true);
      _;
    }

  modifier onlyCreditorOrDebtor(){
    require(msg.sender == creditor || msg.sender == debtor);
    _;
  }

  modifier onlyCreditor(){
    require(msg.sender == creditor);
    _;
  }

  modifier onlyDebtor(){
    require(msg.sender == debtor);
    _;
  }

  modifier onlyContainer(){
    require(msg.sender == container);
    _;
  }

  function () payable {}

  function PromiseEthLoan(address _creditor, address _debtor, uint _amount, uint _terms, uint _rate, uint _periodLength){
    creditor = _creditor;
    debtor = _debtor;
    amount = _amount;
    terms = _terms;
    rate = _rate;
    periodLength = _periodLength;
  }

  function setContainer(address _container) onlyDebtor returns(bool){
    container = _container;
    return true;
  }

  //todo: trustee withdraw funds before lienOn

  function delinquent() constant returns(bool){
      if(lienOn == false){
        return false;
      }
      return paymentOverdue();
  }



  function calcInterest() constant returns(uint){
      return (amount * rate * periodLength) / 10000 / 1 years;
  }

  function loanFinished() constant returns(bool){
      return currentTerm > terms;
  }

  function nextPaymentDue() constant returns(uint){
    uint256 secondsAfter1970 = contractStart.add(periodLength.mul(currentTerm));
    return secondsAfter1970;
  }

  function paymentOverdue() constant returns(bool){
    if(now > nextPaymentDue()){
      return true;
    } else{
      return false;
    }
  }

  function startLien() onlyContainer returns(bool){
    assert(address(this).balance >= amount);
    lienOn = true;
    debtor.transfer(amount);
    currentTerm = 1;
    contractStart = now;
    return true;
  }

  //todo: define grace function
  //todo: define interceptor functions

  function payPremium() payable {
    uint interestDue = calcInterest();
    assert(msg.value >= interestDue);

    uint principal = msg.value - interestDue;
    if(principal > amount){
      amount = 0;
      msg.sender.transfer(principal - amount);
      creditor.transfer(amount + interestDue);
      currentTerm = currentTerm + 1;
      lienOn = false;

    } else {
      creditor.transfer(msg.value);
      amount = amount - principal;
      currentTerm = currentTerm + 1;
    }

  }



}
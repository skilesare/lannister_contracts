PromiseBankLoan = artifacts.require('./PromiseBankLoan.sol')
ControllerERC20Freeze = artifacts.require('./ControllerERC20Freeze.sol')
PromiseContainer = artifacts.require('./PromiseContainer.sol')
HumanStandardToken = artifacts.require('./HumanStandardToken.sol')
DateTime = artifacts.require('./DateTime.sol')

q = require('q') if !q?
accounts = []
async = require("promise-async")
moment = require('moment')
loan = null
control = null
container = null
token = null
tokenStartBalance = 100000 * 10**18;


prepEnvironment = (creditor, debtor)->
  return new Promise (resolve, reject)->
    PromiseBankLoan.new(creditor, debtor, 10**18, 12, 300, 2649600, from: debtor).then (instance)->
      loan = instance
      ControllerERC20Freeze.new( from: debtor)
    .then (instance)->
      control = instance
      PromiseContainer.new(debtor, loan.address ,control.address)
    .then (instance)->
      container = instance
      loan.setContainer(container.address, from: debtor)
    .then (instance)->
      HumanStandardToken.new(tokenStartBalance,"token",0,'tkn', from: debtor)
    .then (instance)->
      token = instance
      Controller.setCollateral(container.address, token.address, 1000 * 10**18, from: creditor)
    .then (instance)->
      web3.eth.sendTransaction({ from: creditor, to: loan.address, value: web3.toWei(1,"ether") })
    .then (instance)->
      container.startLien(from: creditor)
    .catch (error)->
      console.log error






contract 'PromiseContainer', (paccounts)->
  accounts = paccounts
  console.log accounts
  it "should fail if closetrust is called before end of term for token trust", ->
    i = null
    lastTerm = 0
    startBalance = 0
    custodian = null
    currentTerm = 0
    token = null
    secondTrust = null
    #console.log 'starting'
    prepEnvironment(accounts[0], accounts[1])
    .then (instance)->
      loan.amount()
    .then (result)->
      assert.equal result.toNumber(), 10**18, "amount was wrong"
    .catch (error)->
      if error.toString().indexOf("invalid op") > -1
        #console.log("We were expecting a Solidity throw (aka an invalid op), we got one. Test succeeded.")
        assert secondTrust.address.length > 0, true, 'second trust wasnt completed'
        assert.equal error.toString().indexOf("invalid op") > -1, true, 'found an op throw'
      else
        console.log error
        assert(false, error.toString())


###

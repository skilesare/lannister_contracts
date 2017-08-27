PromiseBankLoan = artifacts.require('./PromiseEthLoan.sol')
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
    console.log creditor
    console.log debtor
    HumanStandardToken.new(tokenStartBalance,"token",0,'tkn', from: debtor)
    .then (instance)->
      console.log 'token create'
      token = instance
      PromiseBankLoan.new(creditor, debtor, 10**18, 12, 300, 2649600, from: debtor)
    .then (instance)->
      console.log 'loan Created'
      loan = instance
      ControllerERC20Freeze.new( from: debtor)
    .then (instance)->
      console.log 'freeze created'
      control = instance
      PromiseContainer.new(creditor, token.address, loan.address ,control.address, from: debtor)
    .then (instance)->
      console.log 'container created'
      container = instance
      console.log container.address
      console.log debtor
      loan.debtor()
    .then (result)->
      console.log result
      loan.setContainer(container.address, from: debtor)
    .then (instance)->
      console.log 'container set'

      console.log container.address
      console.log token.address
      console.log creditor
      container.trustee()
    .then (result)->
      console.log result
      control.setCollateral(container.address, token.address, 1000 * 10**18, from: creditor)
    .then (instance)->
      console.log 'collateral set'
      web3.eth.sendTransaction({ from: creditor, to: loan.address, value: web3.toWei(1,"ether") })
    .then (instance)->
      console.log 'transaction done'
      token.transfer(container.address, 1000 * 10**18, from: debtor)
    .then (instance)->
      console.log 'tokens transfered'
      container.owner()
    .then (result)->
      console.log result
      container.promiseContract()
    .then (result)->
      console.log result
      console.log 'calling control contract'
      container.controlContract()
    .then (result)->
      console.log result
      control.token(container.address)
    .then (result)->
      console.log result
      console.log 'calling collateral amount'
      control.collateralAmount(container.address)
    .then (result)->
      console.log result
      console.log 'calling token balance'
      token.balanceOf(container.address)
    .then (result)->
      console.log result
      console.log 'calling canstart'
      control.canStart(container.address, debtor, creditor)
    .then (result)->
      console.log result
      #test that we can transfer tokens before starting
      container.executeFunction(0,"0xa9059cbb","0xa9059cbb000000000000000000000004b01721f0244e7c5b5f63c20942850e447f5a5ee0000000000000000000000000000000000000000000000000000000000000001", from:debtor)
    .then (result)->
      token.balanceOf("0x4b01721f0244e7c5b5f63c20942850e447f5a5ee")
    .then (result) ->
      console.log 'transfered' + result.toNumber()
      container.startLien(from: debtor)
    .then (result)->
      console.log 'started'
      resolve
        loan: loan
    .catch (error)->
      console.log error
      reject error






contract 'PromiseContainer', (paccounts)->
  accounts = paccounts
  console.log accounts
  it "should load amount to loan", ->
    i = null
    lastTerm = 0
    startBalance = 0
    custodian = null
    currentTerm = 0
    token = null
    secondTrust = null
    loanAmount = null
    #console.log 'starting'
    prepEnvironment(accounts[0], accounts[1])
    .then (instance)->
      loan.amount()
    .then (result)->
      loanAmount = result.toNumber()
      assert.equal result.toNumber(), 10**18, "amount was wrong"
      container.executeFunction(0,"0xa9059cbb","0xa9059cbb000000000000000000000004b01721f0244e7c5b5f63c20942850e447f5a5ee0000000000000000000000000000000000000000000000000000000000000001", from:accounts[0])
      #0xa9059cbb000000000000000000000004b01721f0244e7c5b5f63c20942850e447f5a5ee0000000000000000000000000000000000000000000000000000000000000001
    .catch (error)->
      if error.toString().indexOf("invalid op") > -1
        console.log("We were expecting a Solidity throw (aka an invalid op), we got one. Test succeeded.")
        assert.equal loanAmount, 10**18, "amount was wrong 2"
        assert.equal error.toString().indexOf("invalid op") > -1, true, 'found an op throw'
      else
        console.log error
        assert(false, error.toString())


###

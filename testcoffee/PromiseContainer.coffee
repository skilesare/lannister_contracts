PromiseContainer = artifacts.require('./PromiseContainer.sol')

HumanStandardToken = artifacts.require('./HumanStandardToken.sol')
DateTime = artifacts.require('./DateTime.sol')

q = require('q') if !q?
accounts = []
async = require("promise-async")
moment = require('moment')


prepEnvironment = (custodianOwner)->
  return new Promise (resolve, reject)->



contract 'PromiseContainer', (paccounts)->
  accounts = paccounts
  console.log accounts
  it "cant be upgraded if not authorized", ->
  ###
    it "should fail if closetrust is called before end of term for token trust", ->
    i = null
    lastTerm = 0
    startBalance = 0
    custodian = null
    currentTerm = 0
    token = null
    secondTrust = null
    #console.log 'starting'
    prepEnvironment(accounts[0])
    .then (instance)->
      custodian = instance.custodian
      token = instance.token
      console.log "custodian:" + custodian.address
      custodian.CreateTrust(token.address, usdCurrencybytes, 12, 40, {from: accounts[0]})

    .then (txn)->
      trustAddress = null
      txn.logs.map (o)->
        if o.event is 'TrustCreated'
          console.log 'found new Trust at' + o.args.location
          i = FiatTrust.at(o.args.location)
          trustAddress = o.args.location
      console.log 'have instance'
      #fund the wallet
      token.transfer(trustAddress, 5000, { from: accounts[0] })
    .then (result)->
      console.log result
      console.log 'sending ether'
      web3.eth.sendTransaction({ from: accounts[1], to: i.address, value: web3.toWei(.44,"ether") })
    .then (result)->
      i.StartTrust(from:accounts[0])
    .then (result)->
      custodian.CreateTrust(token.address, usdCurrencybytes, 12, 40, {from: accounts[0]})
      .then (txn)->
        trustAddress = null
        txn.logs.map (o)->
          if o.event is 'TrustCreated'
            console.log 'found new Trust at' + o.args.location
            secondTrust = FiatTrust.at(o.args.location)
        console.log 'have second instance'
        console.log secondTrust.address
        assert secondTrust.address.length > 0, true, 'second trust wasnt completed'
        i.UpgradeTo(secondTrust.address, from:accounts[0])
    .then (result)->
      assert.equal false, true, 'shouldnt have been able to close trust'
    .catch (error)->
      if error.toString().indexOf("invalid op") > -1
        #console.log("We were expecting a Solidity throw (aka an invalid op), we got one. Test succeeded.")
        assert secondTrust.address.length > 0, true, 'second trust wasnt completed'
        assert.equal error.toString().indexOf("invalid op") > -1, true, 'found an op throw'
      else
        console.log error
        assert(false, error.toString())


###

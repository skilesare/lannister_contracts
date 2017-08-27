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


Deploying a sample CAC by following the following steps:

1. Create a PromiseEthLoan Contract as the Debtor
2. Create a ControllerERC20Freeze Contact as the Debtor
3. Create the PromiseContainer as the Debtor
4. Call PromiseEthLoan.setContainer on your Loan Contract
5. Set the collateral for for the control contact as the creditor by calling the ControllerERC20Freeze.setCollateralFunction
6. Fund the contract as the creditor by sending the required ETH to the PromiseEthLoan address
7. Start the contract by calling PromiseConatiner.startLien()


Create new Promises by following the iPromise interface.

Create new Control functons by following the iControl interface.
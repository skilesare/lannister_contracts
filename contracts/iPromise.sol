pragma solidity ^0.4.15;


contract iPromise {

bool public lienOn;

function delinquent() constant returns (bool result);
function startLien() returns (bool result);



}
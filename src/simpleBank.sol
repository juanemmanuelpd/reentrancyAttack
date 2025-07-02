// License 
// SPDX-License-Identifier: MIT

// Solidity compiler version
pragma solidity 0.8.24;

// Contract
contract simpleBank {

    // Variables
    mapping(address => uint256) public userBalance;

    // Functions
    function deposit() public payable {
        require(msg.value >= 1 ether, "Minimun deposit is 1 ETH");
        userBalance[msg.sender] += msg.value;
    }

    function withdraw() public {
        require(userBalance[msg.sender] >= 1 ether, "User has not enough balance");
        require(address(this).balance > 0, "Bank is empty");
        (bool success, ) = msg.sender.call{value: userBalance[msg.sender]}("");
        require(success, "fail");
        userBalance[msg.sender] = 0;
    }

    function totalBalance() public view returns(uint){
        return address(this).balance;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

// Write a Solidity function to withdraw funds from a smart contract.
contract Main {

    receive() payable external{}

    function withdraw(uint256 amount) public payable {
        require(amount <= address(this).balance, "No enough fund");
        payable(msg.sender).transfer(amount);
    }

}
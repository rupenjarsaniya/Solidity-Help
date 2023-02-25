// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

// Write a Solidity function to check the balance of a given address.
contract Main {

    function checkBalance(address addr) public view returns(uint256) {
        return addr.balance;
    }

}
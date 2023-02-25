// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

// Write a Solidity function to implement a voting system, where each address can vote only once.
contract Main {

    struct Voter {
        bool voted;
        address delegate;
    }

    mapping(address => Voter) public voters;

    function voting() public {
        require(!voters[msg.sender].voted, "You already give your vote.");
        voters[msg.sender].voted = true;
        voters[msg.sender].delegate = msg.sender;
    }

}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

// Write a Solidity function to implement a time-locked contract, which allows funds to be withdrawn only after a certain time has elapsed.
contract Main {

    mapping(address => uint) public balances;

    mapping(address => uint) public locktime;

    event Console(uint256 timestamp);

    function deposit() external payable {

        balances[msg.sender] += msg.value;
        locktime[msg.sender] = block.timestamp + 1 minutes;
        emit Console(block.timestamp);

    }

    function withdrawn() public {

        require(balances[msg.sender] > 0, "Insuffiencient funds");
        require(block.timestamp > locktime[msg.sender], "Lock time has not expired");
        uint amount = balances[msg.sender];
        balances[msg.sender] = 0;
        (bool sent, ) = msg.sender.call{value: amount}("");
        require(sent, "Failed to send ether");

    }

}
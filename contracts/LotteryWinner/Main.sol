// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

// Write a Solidity function to implement a lottery, where users can buy tickets for a chance to win a prize.

contract Main {
    address[] public players;
    address manager;

    constructor() {
        manager = msg.sender;
    }

    function alreadyExist() private view returns (bool) {
        for (uint256 i = 0; i < players.length; i++) {
            if (players[i] == msg.sender) {
                return true;
            }
        }
        return false;
    }

    function random() private view returns (uint256) {
        return uint256(keccak256(abi.encode(block.timestamp, players)));
    }

    function enter() public payable {
        require(
            msg.value == 1 ether,
            "You must have to pay entry fees of 1 ether"
        );
        require(!alreadyExist(), "You already participated in contest");
        players.push(msg.sender);
    }

    function pickWinner() payable public {
        require(manager == msg.sender, "You can not access.");
        uint index = random() % players.length;
        payable(players[index]).transfer(address(this).balance);
        players = new address[](0);
    }
}

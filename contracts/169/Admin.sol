// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Write a Solidity function to implement a decentralized ride-sharing platform, where users can find and offer rides without relying on a centralized platform.
contract Admin {
    struct UserData {
        address ethAddress;
        string name;
    }

    mapping(address => UserData) public users;

    function register(string memory _name) public {
        require(
            users[msg.sender].ethAddress != msg.sender,
            "This address is already in use"
        );

        users[msg.sender] = UserData(msg.sender, _name);
    }

    function getUser(address _address) public view returns (UserData memory) {
        return users[_address];
    }

    function checkUser(address _address) public view returns(bool) {
        return users[_address].ethAddress != address(0);
    }
}

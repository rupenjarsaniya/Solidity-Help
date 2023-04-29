// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Write a Solidity function to implement a car booking
contract Admin {
    address public admin;

    enum Role {
        PASSENGER,
        DRIVER
    }

    struct UserData {
        address ethAddress;
        Role role;
    }

    mapping (address => UserData) public UserDetail;

    constructor() {
        admin = msg.sender;
    }

    function userRegister(uint _usertype) public {
        require(UserDetail[msg.sender].ethAddress == 0x0000000000000000000000000000000000000000, "User is already registered");

        UserDetail[msg.sender] = UserData(
            msg.sender, Role(_usertype)
        );
    }

    function getUser(address _address) public view returns(UserData memory) {
        return UserDetail[_address];
    }

    function getRole(address _address) public view returns(uint256){
        return uint256(UserDetail[_address].role);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract DecentralizedIdentity {
    struct Identity {
        uint256 id;
        mapping(string => string) attributes;
        mapping(string => bool) proofs;
    }

    mapping(address => Identity) private identities;
    uint256 private totalIdentities;

    modifier onlyExistingIdentity() {
        require(identities[msg.sender].id != 0, "Identity does not exist!");
        _;
    }

    modifier onlyExistingAttribute(string calldata attribute) {
        require(
            keccak256(bytes(identities[msg.sender].attributes[attribute])) !=
                keccak256(bytes("")),
            "Attribute does not exist!"
        );
        _;
    }

    function createIdentity() external {
        require(identities[msg.sender].id == 0, "Identity already exist!");

        totalIdentities++;
        identities[msg.sender].id = totalIdentities;
    }

    function addAttribute(string calldata attribute, string calldata value)
        external
        onlyExistingIdentity
    {
        require(
            keccak256(bytes(identities[msg.sender].attributes[attribute])) ==
                keccak256(bytes("")),
            "Attribute already exist!"
        );
        require(
            keccak256(bytes(value)) != keccak256(bytes("")),
            "Value can not be empty"
        );
        identities[msg.sender].attributes[attribute] = value;
    }

    function addProof(string calldata attribute)
        external
        onlyExistingIdentity
        onlyExistingAttribute(attribute)
    {
        identities[msg.sender].proofs[attribute] = true;
    }

    function getAttribute(address user, string calldata attribute)
        external
        view
        onlyExistingAttribute(attribute)
        returns (string memory)
    {
        return identities[user].attributes[attribute];
    }

    function hasProof(address user, string calldata attribute)
        external
        view
        onlyExistingAttribute(attribute)
        returns (bool)
    {
        return identities[user].proofs[attribute];
    }
}


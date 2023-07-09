// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract StakeHolder {
    enum Status {
        NONE,
        REQUESTED,
        DEACTIVE,
        ACTIVE
    }

    address public owner;
    address[] private stakeholdersEthAddress;
    mapping(address => Status) public stakeholdersStatus;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner has accees");
        _;
    }

    modifier onylStakeholder() {
        require(isStakeholder(msg.sender), "Only stakeholder has access");
        _;
    }

    function requestForStakeholder() external {
        require(!isStakeholder(msg.sender), "Stakeholder dont have access");
        stakeholdersStatus[msg.sender] = Status.REQUESTED;
    }

    function accept(address ethAddress) external onlyOwner {
        require(
            stakeholdersStatus[ethAddress] == Status.REQUESTED,
            "This address was already accepted as stakeholder"
        );
        stakeholdersEthAddress.push(ethAddress);
        stakeholdersStatus[ethAddress] = Status.ACTIVE;
    }

    function deactive() external onylStakeholder {
        require(
            stakeholdersStatus[msg.sender] == Status.ACTIVE,
            "This address is already deactive"
        );
        stakeholdersStatus[msg.sender] = Status.DEACTIVE;
    }

    function active() external onylStakeholder {
        require(
            stakeholdersStatus[msg.sender] == Status.DEACTIVE,
            "This address is already active"
        );
        stakeholdersStatus[msg.sender] = Status.ACTIVE;
    }

    function removeRequest() external {
        require(
            stakeholdersStatus[msg.sender] == Status.REQUESTED,
            "This address was already accepted as stakeholder"
        );
        delete stakeholdersStatus[msg.sender];
    }

    function isStakeholder(address ethAddress) public view returns (bool) {
        if(stakeholdersStatus[ethAddress] == Status.NONE){
            return false;
        }
        return true;
    }

    function getTotalStakeHolders() external view returns(uint){
        return stakeholdersEthAddress.length;
    }

    function getStatus(address ethAddress) external view returns (Status) {
        return stakeholdersStatus[ethAddress];
    }
}

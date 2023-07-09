// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Main {
    struct StorageUnit {
        address renter;
        uint256 rentAmount;
        uint256 rentDuration;
        uint256 rentedAt;
    }

    address public owner;
    uint256 public constant tokenPrice = 0.5 ether;
    uint256 private storageId;

    mapping(address => uint256) public tokenBalance;
    mapping(uint256 => StorageUnit) public storageUnits;

    event StorageUnitRented(uint256 unitId, address renter);
    event StorageUnitReleased(
        uint256 unitId,
        address renter,
        uint256 rentAmount
    );

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner has access to this method");
        _;
    }

    function rentStorageUnit(uint256 rentDuration) external payable {
        require(storageId <= 5, "All units are full");
        require(msg.value >= tokenPrice * rentDuration, "Insufficient payment");

        storageId++;
        storageUnits[storageId] = StorageUnit(
            msg.sender,
            msg.value,
            rentDuration,
            block.timestamp
        );
        tokenBalance[owner] += msg.value;

        emit StorageUnitRented(storageId, msg.sender);
    }

    function releaseStorageUnit(uint256 _storageId) external {
        require(
            storageUnits[_storageId].renter == msg.sender,
            "You dont have access to release this unit"
        );

        uint256 rentAmount = storageUnits[_storageId].rentAmount;
        delete storageUnits[_storageId];

        emit StorageUnitReleased(_storageId, msg.sender, rentAmount);
    }

    function withdrawFunds() external onlyOwner {
        uint256 balance = tokenBalance[owner];

        require(balance > 0, "No funds available");
        
        tokenBalance[owner] = 0;
        delete tokenBalance[owner];
        (bool success, ) = payable(owner).call{value: balance}("");

        require(success, "Failed to transfer funds to owner account");
    }
}

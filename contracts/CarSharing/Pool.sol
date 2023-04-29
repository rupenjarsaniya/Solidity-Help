// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Car.sol";
import "./Admin.sol";

contract Pool {
    CarManage private carManage;
    Admin private admin;

    enum Car_Type {
        NAN,
        SUV,
        HATCHBACK,
        CROSSOVER,
        CONVERTIBLE,
        SEDAN,
        SPORTS,
        COUPE,
        MINIVAN
    }

    struct CarData {
        address owner;
        string carName;
        string plateNumber;
        uint256 seats;
        Car_Type carType;
    }

    struct Ride {
        address owner;
        string from;
        string to;
        uint256 fare;
        uint256 availableSeats;
        bool isActive;
        address joiner;
    }

    uint256 private index;

    struct UserData1 {
        address ethAddress;
        string name;
    }

    struct ManageFare {
        address withdrawBy;
        uint256 fare;
    }

    mapping(uint256 => Ride) public ride;
    mapping(address => uint256[]) public history;
    mapping(address => uint256) public activeRide;
    mapping(address => uint256) public passengersActiveRide;
    mapping(address => ManageFare) public manageFare;

    receive() external payable {}

    constructor(CarManage _carManageAddress, Admin _adminAddress) {
        carManage = _carManageAddress;
        admin = _adminAddress;
    }

    modifier isUser() {
        require(admin.checkUser(msg.sender), "User not registered");
        _;
    }

    modifier isCancelled(uint256 _index) {
        require(ride[_index].isActive, "This ride is already cancelled");
        _;
    }

    modifier isCurrentPassenger(uint256 _index) {
        require(
            ride[_index].joiner == msg.sender,
            "You dont have access to cancel other passegnsers ride"
        );
        _;
    }

    function createRide(
        string memory _from,
        string memory _to,
        uint256 _fare,
        uint256 _availableSeats
    ) public isUser {
        require(activeRide[msg.sender] == 0, "You have already active pooling");
        require(
            carManage.getSeats(msg.sender) - 1 >= _availableSeats,
            "Seats number is invalid"
        );

        index = index + 1;

        ride[index] = Ride({
            owner: msg.sender,
            from: _from,
            to: _to,
            fare: _fare,
            availableSeats: _availableSeats,
            isActive: true,
            joiner: address(0)
        });

        history[msg.sender].push(index);
        activeRide[msg.sender] = index;
    }

    function joinRide(uint256 _index)
        public
        payable
        isUser
        isCancelled(_index)
    {
        Ride storage currentRide = ride[_index];

        require(currentRide.joiner == address(0), "Car is full");
        require(
            currentRide.owner != msg.sender,
            "Owner cannot join his own ride"
        );
        require(
            passengersActiveRide[msg.sender] == 0,
            "You have already taken some ride"
        );
        require(msg.value == currentRide.fare, "Payment amount is invalid");

        (bool success, ) = address(this).call{value: msg.value}("");
        require(success, "Failed to send Ether");

        currentRide.joiner = msg.sender;
        passengersActiveRide[msg.sender] = index;
        manageFare[currentRide.owner] = ManageFare(
            currentRide.owner,
            msg.value
        );
    }

    // This function is only access by owners of the car
    function cancelActiveRide(uint256 _index)
        public
        isUser
        isCancelled(_index)
    {
        Ride storage currentRide = ride[_index];

        require(
            currentRide.owner == msg.sender,
            "You dont have access to cancel this ride"
        );

        if (currentRide.joiner != address(0)) {
            require(
                currentRide.fare == manageFare[msg.sender].fare,
                "Refund is already released or ride is complete"
            );
            passengersActiveRide[currentRide.joiner] = 0;
            manageFare[msg.sender].withdrawBy = currentRide.joiner;
        }

        currentRide.isActive = false;
        activeRide[msg.sender] = 0;
    }

    // This function is only access by passangers
    function cancelPassengersRide(uint256 _index)
        public
        isUser
        isCancelled(_index)
        isCurrentPassenger(_index)
    {
        require(passengersActiveRide[msg.sender] == _index, "Invalid Ride");

        Ride storage currentRide = ride[_index];

        require(
            manageFare[currentRide.owner].fare != 0,
            "You already have withdraw your funds"
        );

        manageFare[currentRide.owner].withdrawBy = msg.sender;

        require(
            manageFare[currentRide.owner].withdrawBy == msg.sender,
            "You cannot access the withdraw"
        );

        (bool success, ) = msg.sender.call{
            value: manageFare[currentRide.owner].fare
        }("");
        require(success, "Failed to send Ether");

        manageFare[currentRide.owner].fare = 0;
        currentRide.joiner = address(0);
        passengersActiveRide[msg.sender] = 0;
    }

    // This function is only access by passangers
    function completeRide(uint256 _index)
        public
        isUser
        isCancelled(_index)
        isCurrentPassenger(_index)
    {
        Ride storage currentRide = ride[_index];
        activeRide[currentRide.owner] = 0;
        passengersActiveRide[msg.sender] = 0;
        currentRide.isActive = false;
        manageFare[currentRide.owner].withdrawBy = currentRide.owner;
    }

    function withdraw(uint256 _index) public isUser {
        Ride storage currentRide = ride[_index];

        require(!ride[_index].isActive, "This ride is active now");
        require(
            manageFare[currentRide.owner].withdrawBy == msg.sender,
            "You cannot access the withdraw"
        );
        require(
            manageFare[currentRide.owner].fare != 0,
            "You already have withdraw your funds"
        );

        (bool success, ) = msg.sender.call{
            value: manageFare[currentRide.owner].fare
        }("");
        require(success, "Failed to send Ether");
        manageFare[currentRide.owner].fare = 0;
    }

    // User interaction functions
    function getCardInfo(uint256 _index)
        public
        view
        returns (CarManage.CarData memory)
    {
        CarManage.CarData memory data = carManage.getCarInfo(
            ride[_index].owner
        );
        return data;
    }

    function getHistory(address _address)
        public
        view
        returns (uint256[] memory)
    {
        return history[_address];
    }

    function getRideByIndex(uint256 _index) public view returns (Ride memory) {
        return ride[_index];
    }
}

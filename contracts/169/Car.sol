// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CarManage {
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

    mapping(address => CarData) public cars;

    function registerCar(
        string memory _carName,
        string memory _plateNumber,
        uint256 _seats,
        uint256 _carType
    ) public {
        require(
            cars[msg.sender].owner == address(0),
            "You have already added a car using this account"
        );

        cars[msg.sender] = CarData(
            msg.sender,
            _carName,
            _plateNumber,
            _seats,
            Car_Type(_carType)
        );
    }

    function getCarInfo(address _address) public view returns (CarData memory) {
        return cars[_address];
    }

    function getSeats(address _address) public view returns (uint256) {
        return cars[_address].seats;
    }

    function deleteCar() public {
        cars[msg.sender] = CarData(msg.sender, "", "", 0, Car_Type(0));
    }
}

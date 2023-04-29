// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Admin.sol";

contract Main {
    Admin public adminContract;

    enum Role {
        PASSENGER,
        DRIVER
    }

    enum Passenger_Status {
        book,
        confirm,
        pick,
        drop,
        cancel
    }

    struct BookingData {
        uint256 bookingId;
        string from;
        string to;
        uint256 kilometers;
        uint256 fare;
        address passengerAddress;
        Passenger_Status status;
        bool isConfirm;
    }

    struct ConfirmationData {
        uint256 OTP;
        address driverAddress;
        uint256 timestamp;
    }

    mapping(uint256 => BookingData) public bookings;
    mapping(uint256 => ConfirmationData) public confirmation;
    mapping(address => bool) public booked;
    mapping(address => bool) public onService;
    mapping(address => uint256[]) public history;

    uint256 private index;
    uint256 private counter;
    uint256 constant fare = 1 ether;

    constructor(Admin _adminAddress) {
        adminContract = _adminAddress;
    }

    modifier onlyOperators() {
        require(
            Role(adminContract.getRole(msg.sender)) == Role.DRIVER,
            "Only operators has access"
        );
        _;
    }

    modifier onlyRiders() {
        require(
            Role(adminContract.getRole(msg.sender)) == Role.PASSENGER,
            "Only riders has access"
        );
        _;
    }

    modifier isCorrectDriver(uint256 _index) {
        require(
            confirmation[_index].driverAddress == msg.sender,
            "You are not driver of this ride"
        );
        _;
    }

    modifier isBooked(uint256 _index) {
        require(
            booked[bookings[_index].passengerAddress],
            "This passenger don't have any ride for now"
        );
        _;
    }

    function bookRide(
        address _address,
        string memory _from,
        string memory _to,
        uint256 _kilometers
    ) public payable onlyRiders {
        require(!booked[_address], "Kindly complete your current ride");

        uint256 totalFare = fare * _kilometers;
        require(msg.value == totalFare, "Payment amount is not valid");

        index++;
        bookings[index] = BookingData({
            bookingId: index,
            from: _from,
            to: _to,
            kilometers: _kilometers,
            fare: totalFare,
            passengerAddress: _address,
            status: Passenger_Status(0),
            isConfirm: false
        });
        booked[_address] = true;
        history[msg.sender].push(index);
    }

    function confirmRide(uint256 _index) public onlyOperators isBooked(_index) {
        BookingData storage currentBooking = bookings[_index];

        require(
            currentBooking.status == Passenger_Status.book,
            "Invalid Booking"
        );
        require(!currentBooking.isConfirm, "Already the ride is confirmed");
        require(!onService[msg.sender], "Please finish your current ride");
        require(
            msg.sender != currentBooking.passengerAddress,
            "Passenger and Driver must not be same"
        );

        confirmation[_index] = ConfirmationData(
            generateOTP(),
            msg.sender,
            block.timestamp
        );
        currentBooking.isConfirm = true;
        currentBooking.status = Passenger_Status(1);
        onService[msg.sender] = true;
    }

    function pickPassenger(uint256 _otp, uint256 _index)
        public
        onlyOperators
        isBooked(_index)
        isCorrectDriver(_index)
    {
        BookingData storage currentBooking = bookings[_index];

        require(
            currentBooking.status == Passenger_Status.confirm,
            "Booking is not confirmed yet"
        );
        require(confirmation[_index].OTP == _otp, "Invalid OTP");

        currentBooking.status = Passenger_Status(2);
    }

    function dropPassenger(uint256 _index)
        public
        onlyOperators
        isBooked(_index)
        isCorrectDriver(_index)
    {
        BookingData storage currentBooking = bookings[_index];

        require(
            currentBooking.status == Passenger_Status.pick,
            "Passenger is not picked yet"
        );

        currentBooking.status = Passenger_Status(3);
        booked[currentBooking.passengerAddress] = false;
        onService[msg.sender] = false;
    }

    function cancelRide(uint256 _index) public isBooked(_index) {
        BookingData storage currentBooking = bookings[_index];

        require(
            currentBooking.status == Passenger_Status.confirm ||
                currentBooking.status == Passenger_Status.book,
            "Now you cannot cancel this ride"
        );

        currentBooking.status = Passenger_Status(4);
        payable(currentBooking.passengerAddress).transfer(currentBooking.fare);
        booked[currentBooking.passengerAddress] = false;
        onService[confirmation[_index].driverAddress] = false;
    }

    // Utils
    function generateOTP() private returns (uint256) {
        counter += 1;
        return
            uint256(
                keccak256(
                    abi.encodePacked(block.timestamp, msg.sender, counter)
                )
            ) % 10000;
    }

    function getCurrentRide(uint256 _index)
        public
        view
        onlyRiders
        returns (BookingData memory)
    {
        return bookings[_index];
    }

    function getHistoryRide(address _address)
        public
        view
        onlyRiders
        returns (uint256[] memory)
    {
        return history[_address];
    }
}

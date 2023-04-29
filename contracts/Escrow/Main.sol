// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/*Write a Solidity function to implement a trustless escrow system,
 where funds are held in escrow until certain condition are met.*/

contract AEscrow {
    address public mediator;
    enum situation {
        LOCKED,
        DELIVERED,
        INACTIVE
    }
    struct Seller {
        address seller;
        uint256 amount;
        situation state;
    }
    mapping(address => Seller[]) public transactions;

    event Lock(address buyer, address seller, uint256 amount);
    event Delivered(address buyer, address seller);
    event Release(address buyer, address seller, uint256 amount);
    event Refund(address buyer, address seller, uint256 amount);

    constructor() {
        mediator = msg.sender;
    }

    modifier onlyMediator() {
        require(mediator == msg.sender, "You dont have access!");
        _;
    }

    modifier notOnlyMediator(address _sellerAddress, address _buyerAddress) {
        require(mediator != _sellerAddress, "Mediator cannot be seller");
        require(mediator != _buyerAddress, "Mediator cannot be buyer");
        _;
    }

    modifier yourSelf(address _address) {
        require(msg.sender != _address, "You don't have access");
        _;
    }

    function lock(address _seller)
        public
        payable
        yourSelf(_seller)
        notOnlyMediator(_seller, msg.sender)
    {
        require(msg.value > 0, "Invalid amount");
        bool flag = false;

        for (uint256 i = 0; i < transactions[msg.sender].length; i++) {
            if (transactions[msg.sender][i].seller == _seller) {
                transactions[msg.sender][i].amount =
                    transactions[msg.sender][i].amount +
                    msg.value;
                transactions[msg.sender][i].state = situation.LOCKED;
                flag = true;
            }
        }

        if (!flag) {
            transactions[msg.sender].push(
                Seller(_seller, msg.value, situation.LOCKED)
            );
        }

        emit Lock(msg.sender, _seller, msg.value);
    }

    function delivered(address _buyer, address _seller) public onlyMediator {
        for (uint256 i = 0; i < transactions[_buyer].length; i++) {
            if (transactions[_buyer][i].seller == _seller) {
                transactions[_buyer][i].state = situation.DELIVERED;
            }
        }

        emit Delivered(_buyer, _seller);
    }

    function release(address _buyer)
        public
        yourSelf(_buyer)
        notOnlyMediator(msg.sender, _buyer)
    {
        for (uint256 i = 0; i < transactions[_buyer].length; i++) {
            if (transactions[_buyer][i].seller == msg.sender) {
                require(
                    transactions[_buyer][i].state == situation.DELIVERED,
                    "Invalid request"
                );

                transactions[_buyer][i].state = situation.INACTIVE;
                payable(msg.sender).transfer(transactions[_buyer][i].amount);

                emit Release(
                    _buyer,
                    msg.sender,
                    transactions[_buyer][i].amount
                );
            }
        }
    }

    function refund(address _seller)
        public
        yourSelf(_seller)
        notOnlyMediator(_seller, msg.sender)
    {
        for (uint256 i = 0; i < transactions[msg.sender].length; i++) {
            if (transactions[msg.sender][i].seller == _seller) {
                require(
                    transactions[msg.sender][i].state == situation.LOCKED,
                    "Invalid request"
                );

                payable(msg.sender).transfer(
                    transactions[msg.sender][i].amount
                );
                transactions[msg.sender][i].amount = 0;
                transactions[msg.sender][i].state = situation.INACTIVE;

                emit Refund(
                    msg.sender,
                    _seller,
                    transactions[msg.sender][i].amount
                );
            }
        }
    }
}

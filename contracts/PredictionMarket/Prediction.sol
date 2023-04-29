// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Token.sol";

contract Prediction {
    address public admin;
    address public winner;
    Token public token;

    struct PredictionData {
        address participate;
        uint256 amount;
        bool redeemed;
    }

    PredictionData[] public predictions;

    constructor(Token _token) {
        admin = msg.sender;
        token = _token;
    }

    modifier isNotAdmin() {
        require(admin != msg.sender, "Admin don't have an access");
        _;
    }

    modifier isAdmin() {
        require(admin == msg.sender, "You don't have an access");
        _;
    }

    function predict(uint256 _amount) public isNotAdmin {
        token.transferFrom(msg.sender, address(this), _amount);
        predictions.push(PredictionData(msg.sender, _amount, false));
    }

    function redeemReward(uint256 _index) public isNotAdmin {
        require(
            winner != 0x0000000000000000000000000000000000000000,
            "Winner not declared yet"
        );
        require(
            winner == predictions[_index].participate,
            "You are loose, try next time"
        );
        require(winner == msg.sender, "You can not cliam others reward");
        require(
            !predictions[_index].redeemed,
            "You have already redeem your reward"
        );

        uint256 reward = predictions[_index].amount * 2;
        require(token.balanceOf(address(this)) >= reward, "Contract don't have enoght tokens");

        token.transfer(msg.sender, reward);
        predictions[_index].amount = 0;
        predictions[_index].redeemed = true;
    }

    function declareWinner() public isAdmin {
        require(
            winner == 0x0000000000000000000000000000000000000000,
            "Winner is already declared"
        );

        uint256 index = random() % predictions.length;
        winner = predictions[index].participate;
    }

    function random() private view returns (uint256) {
        return
            uint256(
                keccak256(
                    abi.encodePacked(
                        block.difficulty,
                        block.timestamp,
                        predictions.length
                    )
                )
            );
    }
}

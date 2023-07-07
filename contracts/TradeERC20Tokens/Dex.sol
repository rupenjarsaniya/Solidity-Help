// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import "./Token.sol";

contract Dex {
    Token token;
    uint constant tokenPrice = 0.5 ether;

    constructor(Token _token) payable {
        require(msg.value > 0, "You have to atleast deposit something to start a DEX");
        token = _token;
    }

    function buy() payable public {
        require(msg.value > 0, "You need to send some ethers");

        uint amountToBuy = msg.value / tokenPrice;
        uint dexBalance  = token.balanceOf(address(this));

        require(amountToBuy > 0, "You need to send enough ethers to buy tokens");
        require(amountToBuy <= dexBalance, "Not enought tokens in DEX");

        token.transfer(msg.sender, amountToBuy);
    }
    
    function sell(uint amount) public {
        require(amount > 0, "You need to sell at least some tokens");

        uint approveAmt = token.allowance(msg.sender, address(this));

        require(approveAmt >= amount, "Check the token allowance");

        token.transferFrom(msg.sender, payable(address(this)), amount);
        uint sellAmount = amount * tokenPrice;
        payable(msg.sender).transfer(sellAmount);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./ExchangeToken.sol";

contract Exchange {
    address owner;
    YourToken public token;
    uint256 public tokenPrice;
    uint256 public tokensSold;

    event Buy(address _buyer, uint256 amount);
    event Sell(address _from , address _to, uint256 amount);

    constructor(YourToken _tokenContract, uint256 _tokenPrice) {
        owner = msg.sender;
        token = _tokenContract;
        tokenPrice = _tokenPrice;
    }

    function buyToken(uint _numberOfTokens) public payable {
        require(msg.value > 0, "You need to send some ethers");

        uint256 dexBalance = token.balanceOf(address(this));

        require(msg.value <= dexBalance, "Not enough tokens in the reserve");
        require(msg.value == _numberOfTokens * tokenPrice, "You need to send ether according to current price of token");

        token.transfer(msg.sender, _numberOfTokens);
        emit Buy(msg.sender, _numberOfTokens);
    }

    function sellToken(uint _numberOfTokens) public {
        require(_numberOfTokens > 0, "You need to sell at least some tokens");
        
        uint256 allowance = token.allowance(msg.sender, address(this));

        require(allowance >= _numberOfTokens, "Check the token allowance");
        
        token.transferFrom(msg.sender, address(this), _numberOfTokens);
        payable(msg.sender).transfer(_numberOfTokens);
        emit Sell(msg.sender, address(this), _numberOfTokens);
    }
}
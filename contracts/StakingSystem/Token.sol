// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Token is ERC20 {
    constructor() ERC20 ("My Token", "MT"){
        _mint(msg.sender, 50 * 10 ** decimals());
    }
}
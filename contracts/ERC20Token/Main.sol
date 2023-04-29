// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

// Write a Solidity function to implement a basic ERC-20 token.

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Main is ERC20{

    constructor() ERC20 ("ERC20 Token", "ERC"){
        _mint(msg.sender, 50 * 10 ** decimals());
    }

}
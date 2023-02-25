// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

// Write a Solidity function to transfer tokens from one address to another.

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Main is ERC20 {
    constructor() ERC20("Mango", "MAG"){
        _mint(msg.sender, 500 * 10 ** decimals());
    }

    function transferToken(address to, uint amount) public {
        transfer(to, amount);
    }
}


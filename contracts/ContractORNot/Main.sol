// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

// Write a Solidity function to check if a given address is a contract or not.
contract Main{ 
    event Console(uint size);

    // Method 1
    function checkContract(address _addr) public view returns(bool){
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        bytes32 codehash;

        assembly{
            codehash := extcodehash(_addr)
        }
        return(codehash != 0x0 && codehash != accountHash);
    }

    // Method 2
    function isContract(address _addr) public view returns(bool){
        uint size;
        assembly {
            size := extcodesize(_addr)
        }
        return size > 0;
    }

    // Method 3
    function isContractFun(address _addr) public view returns(bool){
        return _addr.code.length > 0;
    }
}
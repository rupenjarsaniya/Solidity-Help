// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Controller.sol";
import "./JobHandler.sol";

contract JobApplication {
    JobHandler private jobHandler;
    Controller private controller;

    constructor(JobHandler jobHandlerAddress, Controller authAddress) {
        jobHandler = jobHandlerAddress;
        controller = authAddress;
    }

    modifier isUser() {
        require(controller.checkUser(msg.sender), "User not found");
        _;
    }

    function applyForJob(uint256 jobId, address companyAddress) external isUser {
        jobHandler.applyNow(msg.sender, companyAddress, jobId);
    }

    function getApplicationByJobId(uint256 jobId, address companyAddress)
        external
        view
        isUser
        returns (JobHandler.ApplicationData memory)
    {
        return jobHandler.getApplicationByJobId(msg.sender, companyAddress, jobId);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Controller.sol";

contract JobHandler {
    uint256 private index;
    Controller private controller;

    enum Experience {
        FRESHER,
        INTERNSHIP,
        INTERMEDIATE,
        PROFESSIONALS
    }
    enum Schedule {
        MONDAYTOFRIDAY,
        MONDAYTOSATURDAY
    }
    enum JobType {
        FULLTIME,
        PARTTIME
    }
    enum JobMode {
        ONSITE,
        REMOTE
    }
    enum Status {
        NOTAPPLYED,
        APPLYED,
        REVIEWED,
        INPROGRESS,
        SELECTED,
        REJECTED
    }
    struct ApplicationData {
        address applierAddress;
        address companyAddress;
        Status status;
    }
    struct JobData {
        address companyAddress;
        string title;
        Experience experience;
        string[] technologies;
        bool isOpen;
        string salary;
        Schedule schedule;
        JobType jobType;
        JobMode jobMode;
        string[] qualifications;
        uint256 vacancy;
        string highestEducation;
        uint256 timestamp;
    }
    mapping(uint256 => JobData) private jobs;
    mapping(uint256 => ApplicationData[]) private applications;
    mapping(address => uint256[]) private historyJobPost;
    mapping(uint256 => mapping(address => string)) private offerLetters;

    event PostJob(
        address companyAddress,
        string title,
        Experience experience,
        string[] technologies
    );
    event ApplyNow(address applier, address companyAddress, uint256 jobId);
    event ApplicationStatus(uint256 status, uint256 jobId, address applier);
    event CloseJob(address companyAddress, bool isOpen);
    event GenerateOfferLetter(
        address applier,
        address companyAddress,
        string url,
        uint256 jobId
    );

    constructor(Controller controllerAddress) {
        controller = controllerAddress;
    }

    // Post new job opening
    function postJob(
        string memory title,
        uint256 experience,
        string[] memory technologies,
        string memory salary,
        uint256 schedule,
        uint256 jobType,
        uint256 jobMode,
        string[] memory qualifications,
        uint256 vacancy,
        string memory highestEducation
    ) external {
        address companyEthAddress = controller
            .getCompany(msg.sender)
            .ethAddress;

        require(
            companyEthAddress == msg.sender,
            "You don't have access to post a job on this company"
        );

        index++;

        jobs[index] = JobData(
            companyEthAddress,
            title,
            Experience(experience),
            technologies,
            true,
            salary,
            Schedule(schedule),
            JobType(jobType),
            JobMode(jobMode),
            qualifications,
            vacancy,
            highestEducation,
            block.timestamp
        );

        historyJobPost[companyEthAddress].push(index);

        emit PostJob(
            companyEthAddress,
            title,
            Experience(experience),
            technologies
        );
    }

    // Apply now
    function applyNow(
        address applier,
        address companyAddress,
        uint256 jobId
    ) external {
        JobData storage currentJob = jobs[jobId];

        require(
            currentJob.companyAddress == companyAddress,
            "Company address is not valid"
        );
        require(
            currentJob.companyAddress != applier,
            "You cannot apply in your own company"
        );
        require(currentJob.isOpen, "Job is closed");

        for (uint256 i = 0; i < applications[jobId].length; i++) {
            require(
                applications[jobId][i].applierAddress != applier,
                "You already applyed for this job."
            );
        }

        applications[jobId].push(
            ApplicationData(applier, companyAddress, Status(1))
        );

        emit ApplyNow(applier, companyAddress, jobId);
    }

    function applicationStatus(
        uint256 status,
        uint256 jobId,
        address applier
    ) external {
        require(jobs[jobId].vacancy != 0, "All vacancy fullfield");
        require(status != 0, "Invalid status");

        (Status _status, uint256 _index) = getApplicationStatus(
            applier,
            msg.sender,
            jobId
        );

        require(_status != Status.SELECTED, "This user is selected");
        require(_status != Status.REJECTED, "This user is rejected");

        if (Status(status) != Status.REJECTED) {
            require(
                _status == Status(status - 1),
                "Right now application cannot be change to given status"
            );
        }

        applications[jobId][_index].status = Status(status);
        if (applications[jobId][_index].status == Status(status)) {
            jobs[jobId].vacancy--;
        }

        emit ApplicationStatus(status, jobId, applier);
    }

    // Close job
    function closeJob(uint256 jobId) external {
        require(
            jobs[jobId].companyAddress == msg.sender,
            "You don't have an access"
        );
        require(jobs[jobId].isOpen, "Job is already close");

        jobs[jobId].isOpen = false;

        emit CloseJob(msg.sender, jobs[jobId].isOpen);
    }

    // Offer Letter
    function generateOfferLetter(
        uint256 jobId,
        uint256 _index,
        string memory url
    ) external {
        ApplicationData memory application = applications[jobId][_index];

        require(
            application.status == Status.SELECTED,
            "This user is not selected"
        );
        require(
            keccak256(bytes(offerLetters[jobId][application.applierAddress])) ==
                keccak256(bytes("")),
            "Offer letter was provided"
        );

        offerLetters[jobId][application.applierAddress] = url;

        emit GenerateOfferLetter(
            application.applierAddress,
            msg.sender,
            url,
            jobId
        );
    }

    function getOfferLetter(uint256 jobId)
        external
        view
        returns (string memory)
    {
        require(
            keccak256(bytes(offerLetters[jobId][msg.sender])) !=
                keccak256(bytes("")),
            "You are not selected yet."
        );
        return offerLetters[jobId][msg.sender];
    }

    function getJobById(address companyAddress, uint256 jobId)
        external
        view
        returns (JobData memory)
    {
        require(
            jobs[jobId].companyAddress == companyAddress,
            "Company address is not valid"
        );
        return jobs[jobId];
    }

    function getAllJobs(address companyAddress)
        external
        view
        returns (JobData[] memory)
    {
        JobData[] memory jobData = new JobData[](
            historyJobPost[companyAddress].length
        );
        for (uint256 i = 0; i < historyJobPost[companyAddress].length; i++) {
            jobData[i] = jobs[historyJobPost[companyAddress][i]];
        }
        return jobData;
    }

    function getAllApplicationsByJobId(uint256 jobId)
        external
        view
        returns (ApplicationData[] memory)
    {
        for (uint256 i = 0; i < applications[jobId].length; i++) {
            require(
                applications[jobId][i].companyAddress == msg.sender,
                "Company Address Not Matched"
            );
        }
        return applications[jobId];
    }

    function getApplicationByJobId(
        address applierAddress,
        address companyAddress,
        uint256 jobId
    ) external view returns (ApplicationData memory) {
        for (uint256 i = 0; i < applications[jobId].length; i++) {
            if (
                applications[jobId][i].applierAddress == applierAddress &&
                applications[jobId][i].companyAddress == companyAddress
            ) {
                return applications[jobId][i];
            }
        }
        return ApplicationData(address(0), address(0), Status(0));
    }

    function getApplicationStatus(
        address applierAddress,
        address companyAddress,
        uint256 jobId
    ) public view returns (Status, uint256) {
        for (uint256 i = 0; i < applications[jobId].length; i++) {
            if (applications[jobId][i].applierAddress == applierAddress) {
                require(
                    applications[jobId][i].companyAddress == companyAddress,
                    "Company address is not valid"
                );
                return (applications[jobId][i].status, i);
            }
        }
        return (Status.NOTAPPLYED, 0);
    }
}

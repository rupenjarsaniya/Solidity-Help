// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Controller {
    struct SocialLinks {
        string linkedin;
        string twitter;
        string github;
        string medium;
    }
    struct Education {
        string collegeName;
        string degree;
        uint256 grade;
        uint256 passingYear;
    }
    struct WorkExperience {
        string companyName;
        string location;
        string designation;
        string currentLPA;
        string[] technologies;
    }
    struct UserData {
        address ethAddress;
        string name;
        SocialLinks socialLinks;
        mapping(address => Education[]) education;
        mapping(address => WorkExperience[]) workExperience;
        string[] resume;
    }
    struct CompanyData {
        address ethAddress;
        string name;
        uint256 employees;
        string headQuarter;
        string website;
        string[] technologies;
        uint256 since;
        string description;
    }
    mapping(address => UserData) private user;
    mapping(address => CompanyData) private company;
    event RegisterUser(
        address ethAddress,
        string name,
        SocialLinks socialLinks,
        Education[] education,
        WorkExperience[] workExperience,
        string[] resume
    );
    event RegisterCompany(
        address ethAddress,
        string name,
        uint256 employees,
        string headQuarter,
        string website,
        string[] technologies,
        uint256 since,
        string description
    );
    event UpdateDescription(string description);
    event UpdateTechnologies(string[] technologies);
    event UpdateWebsite(string website);
    event UpdateHeadQuarter(string headQuarter);
    event UpdateEmployees(uint256 employees);

    modifier isCompanyOwner() {
        require(
            company[msg.sender].ethAddress == msg.sender,
            "You dont have access"
        );
        _;
    }

    modifier isUser() {
        require(checkUser(msg.sender), "User not valid");
        _;
    }

    // Company controller
    function registerCompany(
        string memory name,
        uint256 employees,
        string memory headQuarter,
        string memory website,
        string[] memory technologies,
        uint256 since,
        string memory description
    ) external {
        require(
            user[msg.sender].ethAddress != msg.sender,
            "This address is own by user"
        );
        require(
            company[msg.sender].ethAddress == address(0),
            "Company is registered"
        );

        company[msg.sender] = CompanyData(
            msg.sender,
            name,
            employees,
            headQuarter,
            website,
            technologies,
            since,
            description
        );

        emit RegisterCompany(
            msg.sender,
            name,
            employees,
            headQuarter,
            website,
            technologies,
            since,
            description
        );
    }

    function updateDescription(string memory description)
        external
        isCompanyOwner
    {
        company[msg.sender].description = description;
        emit UpdateDescription(description);
    }

    function updateTechnologies(string[] memory technologies)
        external
        isCompanyOwner
    {
        company[msg.sender].technologies = technologies;
        emit UpdateTechnologies(technologies);
    }

    function updateWesbite(string memory website) external isCompanyOwner {
        company[msg.sender].website = website;
        emit UpdateWebsite(website);
    }

    function updateHeadQuarter(string memory headQuarter)
        external
        isCompanyOwner
    {
        company[msg.sender].headQuarter = headQuarter;
        emit UpdateHeadQuarter(headQuarter);
    }

    function updateEmployees(uint256 employees) external isCompanyOwner {
        company[msg.sender].employees = employees;
        emit UpdateEmployees(employees);
    }

    function getCompany(address _address)
        external
        view
        returns (CompanyData memory)
    {
        return company[_address];
    }

    // User controller
    function registerUser(
        string memory name,
        SocialLinks memory socialLinks,
        Education[] memory education,
        WorkExperience[] memory workExperience,
        string[] memory resume
    ) external {
        require(
            company[msg.sender].ethAddress != msg.sender,
            "This address is own by company"
        );

        require(
            user[msg.sender].ethAddress == address(0),
            "User already registered"
        );

        UserData storage userData = user[msg.sender];
        userData.ethAddress = msg.sender;
        userData.name = name;
        userData.socialLinks = socialLinks;
        for (uint256 i = 0; i < education.length; i++) {
            userData.education[msg.sender].push(education[i]);
        }
        for (uint256 i = 0; i < workExperience.length; i++) {
            userData.workExperience[msg.sender].push(workExperience[i]);
        }
        userData.resume = resume;

        emit RegisterUser(
            msg.sender,
            name,
            socialLinks,
            education,
            workExperience,
            resume
        );
    }

    function addResume(string memory resume) external isUser {
        user[msg.sender].resume.push(resume);
    }

    function deleteResume(uint256 index) external isUser {
        string[] storage resumes = user[msg.sender].resume;
        require(index <= resumes.length, "");

        for (uint256 i = index; i < resumes.length - 1; i++) {
            resumes[i] = resumes[i + 1];
        }
        resumes.pop();
    }

    function getUser(address _address)
        external
        view
        returns (
            address,
            string memory,
            SocialLinks memory,
            Education[] memory,
            WorkExperience[] memory,
            string[] memory
        )
    {
        UserData storage userData = user[_address];
        return (
            userData.ethAddress,
            userData.name,
            userData.socialLinks,
            userData.education[_address],
            userData.workExperience[_address],
            userData.resume
        );
    }

    function checkUser(address _address) public view returns (bool) {
        return user[_address].ethAddress == _address ? true : false;
    }
}

// ["a", "b","c","d"]
// [["a", "b", 1, 2], ["a", "b", 1, 2]]
// [["a", "b", "c", "d", ["a", "b"]]]

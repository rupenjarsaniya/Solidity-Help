// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./Token.sol";
import "./StakeHolder.sol";

contract Main {
    struct Stakeholders {
        uint256 timestamp;
        uint256 reward;
        uint256 balance;
    }

    StakeHolder private stakeholder;
    Token private token;
    mapping(address => Stakeholders) public stakeholders;
    uint256 private totalStake;
    uint256 private totalReward;
    uint256 public constant rate = 1;

    event Staked(address indexed ethAddress, uint256 amount);
    event Unstaked(address indexed ethAddress, uint256 amount);
    event ClaimedRewards(address indexed ethAddress, uint256 amount);

    constructor(Token tokenAddress, StakeHolder stakeholderAddress) {
        token = tokenAddress;
        stakeholder = stakeholderAddress;
    }

    modifier onylStakeholder() {
        require(stakeholder.isStakeholder(msg.sender), "Only stakeholder has access");
        _;
    }

    modifier isActive() {
        require(
            stakeholder.getStatus(msg.sender) == StakeHolder.Status.ACTIVE,
            "This address is not active"
        );
        _;
    }

    function stake(uint256 amount) external onylStakeholder isActive {
        require(amount > 0, "Insufficient amount to holding token");

        token.transferFrom(msg.sender, address(this), amount);

        Stakeholders storage newStakeholder = stakeholders[msg.sender];
        newStakeholder.balance += amount;
        newStakeholder.timestamp = block.timestamp;
        totalStake += amount;

        emit Staked(msg.sender, amount);
    }

    function unstake(uint256 amount) external onylStakeholder isActive {
        require(amount > 0, "Insufficient amount to unholding token");

        Stakeholders storage _stakeholder = stakeholders[msg.sender];
        require(
            _stakeholder.balance >= amount,
            "Insufficient stake token balance"
        );

        uint256 reward = calculateRewards(msg.sender, amount);

        _stakeholder.reward += reward;
        _stakeholder.balance -= amount;
        totalStake -= amount;

        emit Unstaked(msg.sender, amount);
    }

    function claimReward() external onylStakeholder isActive {
        Stakeholders storage _stakeholder = stakeholders[msg.sender];

        require(_stakeholder.reward > 0, "Insufficient reward balance");

        token.transfer(msg.sender, _stakeholder.reward);
        emit ClaimedRewards(msg.sender, _stakeholder.reward);

        _stakeholder.reward = 0;
    }

    function removeStake() external isActive {
        delete stakeholders[msg.sender];
    }

    function getStakeInfo()
        external
        view
        isActive
        returns (Stakeholders memory)
    {
        return stakeholders[msg.sender];
    }

    function getTotalRewards() external view returns (uint256) {
        return totalReward;
    }

    function getTotalStake() external view returns (uint256) {
        return totalStake;
    }

    function calculateRewards(address ethAddress, uint256 amount)
        private
        view
        returns (uint256)
    {
        Stakeholders memory _stakeholder = stakeholders[ethAddress];

        uint256 duration = block.timestamp - _stakeholder.timestamp;
        uint256 reward = duration * amount;

        return reward;
    }
}

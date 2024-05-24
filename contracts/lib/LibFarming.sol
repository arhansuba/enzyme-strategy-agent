// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

library LibFarming {
    struct Farming {
        mapping(address => uint256) stakedAmounts;
        mapping(address => uint256) rewardsEarned;
        address owner;
        IERC20 token;
    }

    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);
    event RewardClaimed(address indexed user, uint256 amount);

    function initialize(Farming storage self, address _owner, address _token) internal {
        require(_owner != address(0), "Owner address cannot be zero");
        require(_token != address(0), "Token address cannot be zero");
        self.owner = _owner;
        self.token = IERC20(_token);
    }

    function stake(Farming storage self, address _user, uint256 _amount) internal {
        require(_user != address(0), "User address cannot be zero");
        require(_amount > 0, "Staking amount must be greater than zero");
        self.stakedAmounts[_user] += _amount;
        emit Staked(_user, _amount);
    }

    function unstake(Farming storage self, address _user, uint256 _amount) internal {
        require(_user != address(0), "User address cannot be zero");
        require(_amount > 0, "Unstaking amount must be greater than zero");
        require(self.stakedAmounts[_user] >= _amount, "Insufficient staked amount");
        self.stakedAmounts[_user] -= _amount;
        emit Unstaked(_user, _amount);
    }

    function claimReward(Farming storage self, address _user, uint256 _amount) internal {
        require(_user != address(0), "User address cannot be zero");
        require(_amount > 0, "Claimed amount must be greater than zero");
        self.rewardsEarned[_user] += _amount;
        emit RewardClaimed(_user, _amount);
    }

    function getStakedAmount(Farming storage self, address _user) internal view returns (uint256) {
        return self.stakedAmounts[_user];
    }

    function getRewardsEarned(Farming storage self, address _user) internal view returns (uint256) {
        return self.rewardsEarned[_user];
    }

    function getOwner(Farming storage self) internal view returns (address) {
        return self.owner;
    }

    function getToken(Farming storage self) internal view returns (IERC20) {
        return self.token;
    }
}

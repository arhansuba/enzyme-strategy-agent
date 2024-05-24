// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IEnzymeVaultMinter.sol";
import "./interfaces/IEnzymeVaultStake.sol";
import "./interfaces/IEnzymeVaultZapper.sol";
import "./interfaces/IEnzymeVaultRewards.sol";
import "./interfaces/IEnzymeVaultStakingRewards.sol";

contract EnzymeVaultController is Ownable {
    IEnzymeVaultMinter public vaultMinter;
    IEnzymeVaultStake public vaultStake;
    IEnzymeVaultZapper public vaultZapper;
    IEnzymeVaultRewards public vaultRewards;
    IEnzymeVaultStakingRewards public vaultStakingRewards;

    constructor(
        address _vaultMinter,
        address _vaultStake,
        address _vaultZapper,
        address _vaultRewards,
        address _vaultStakingRewards
    ) {
        vaultMinter = IEnzymeVaultMinter(_vaultMinter);
        vaultStake = IEnzymeVaultStake(_vaultStake);
        vaultZapper = IEnzymeVaultZapper(_vaultZapper);
        vaultRewards = IEnzymeVaultRewards(_vaultRewards);
        vaultStakingRewards = IEnzymeVaultStakingRewards(_vaultStakingRewards);
    }

    // Modifier to restrict access to only the contract owner
    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function deposit(address _recipient, uint256 _amount, uint256 _shares) external onlyOwner {
        vaultZapper.deposit(_recipient, _amount, _shares);
    }

    function withdraw(address _recipient, uint256 _shares, uint256 _minAmount) external onlyOwner {
        vaultZapper.withdraw(_recipient, _shares, _minAmount);
    }

    function stake(address _recipient, uint256 _shares, uint256 _minAmount) external onlyOwner {
        vaultStake.stake(_recipient, _shares, _minAmount);
    }

    function unstake(address _recipient, uint256 _shares) external onlyOwner {
        vaultStake.unstake(_recipient, _shares);
    }

    function claimRewards(address _recipient) external onlyOwner {
        uint256 rewardAmount = vaultRewards.getReward(_recipient);
        uint256 stakingRewardAmount = vaultStakingRewards.getStakingReward(_recipient);
        require(rewardAmount > 0 || stakingRewardAmount > 0, "No rewards to claim");
        if (rewardAmount > 0) {
            vaultRewards.transfer(_recipient, rewardAmount);
        }
        if (stakingRewardAmount > 0) {
            vaultStakingRewards.transfer(_recipient, stakingRewardAmount);
        }
    }

    function getShares(address _account) external view returns (uint256) {
        return vaultStake.balanceOf(_account);
    }

    function getTotalShares() external view returns (uint256) {
        return vaultStake.totalSupply();
    }

    function getTotalAssets() external view returns (uint256) {
        return vaultMinter.totalSupply();
    }

    function getPricePerShare() external view returns (uint256) {
        return vaultMinter.getPricePerShare();
    }
}
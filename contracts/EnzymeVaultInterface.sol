pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

interface IEnzymeVaultMinter is IERC20 {
    function mint(address _recipient, uint256 _amount) external;
}

interface IEnzymeVaultStake is IERC20 {
    function stake(address _recipient, uint256 _shares, uint256 _minAmount) external;
    function unstake(address _recipient, uint256 _shares) external;
    function claimRewards(address _recipient) external;
}

interface IEnzymeVaultZapper {
    function deposit(address _recipient, uint256 _amount, uint256 _shares) external;
    function withdraw(address _recipient, uint256 _shares, uint256 _minAmount) external;
}

interface IEnzymeVaultRewards is IERC20 {
    function getRewardRate() external view returns (uint256);
    function getReward(address _account) external view returns (uint256);
}

interface IEnzymeVaultStakingRewards is IERC20 {
    function getStakingRewardRate() external view returns (uint256);
    function getStakingReward(address _account) external view returns (uint256);
}

contract EnzymeVaultInterface is Ownable {
    using SafeMath for uint256;

    IEnzymeVaultMinter public vaultMinter;
    IEnzymeVaultStake public vaultStake;
    IEnzymeVaultZapper public vaultZapper;
    IEnzymeVaultRewards public vaultRewards;
    IEnzymeVaultStakingRewards public vaultStakingRewards;

    constructor(address _vaultMinter, address _vaultStake, address _vaultZapper, address _vaultRewards, address _vaultStakingRewards) {
        vaultMinter = IEnzymeVaultMinter(_vaultMinter);
        vaultStake = IEnzymeVaultStake(_vaultStake);
        vaultZapper = IEnzymeVaultZapper(_vaultZapper);
        vaultRewards = IEnzymeVaultRewards(_vaultRewards);
        vaultStakingRewards = IEnzymeVaultStakingRewards(_vaultStakingRewards);
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
        uint256 totalAssets = getTotalAssets();
        uint256 totalShares = getTotalShares();
        if (totalAssets == 0 || totalShares == 0) {
            return 0;
        }
        return totalAssets.div(totalShares);
    }

    function getRewardRate() external view returns (uint256) {
        return vaultRewards.getRewardRate();
    }

    function getStakingRewardRate() external view returns (uint256) {
        return vaultStakingRewards.getStakingRewardRate();
    }
}
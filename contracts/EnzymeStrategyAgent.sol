pragma solidity ^0.8.0;

import "@enzymefinance/protocol/contracts/external-interfaces/IEnzymeVault.sol";
import "@enzymefinance/protocol/contracts/external-interfaces/IEnzymeVaultMinter.sol";
import "@enzymefinance/protocol/contracts/external-interfaces/IEnzymeVaultStake.sol";
import "@enzymefinance/protocol/contracts/external-interfaces/IEnzymeVaultStakeRewards.sol";
import "@enzymefinance/protocol/contracts/external-interfaces/IEnzymeVaultZapper.sol";
import "@enzymefinance/protocol/contracts/external-interfaces/ICompoundV3Pool.sol";
import "@enzymefinance/protocol/contracts/external-interfaces/IAaveV2LendingPool.sol";
import "@enzymefinance/protocol/contracts/external-interfaces/IBalancerV2Pool.sol";
import "@enzymefinance/protocol/contracts/external-interfaces/ICurveLiquidityPool.sol";
import "@enzymefinance/protocol/contracts/lib/LibAddressManager.sol";
import "@enzymefinance/protocol/contracts/lib/LibBeacon.sol";
import "@enzymefinance/protocol/contracts/lib/LibBudget.sol";
import "@enzymefinance/protocol/contracts/lib/LibCrossChainOracle.sol";
import "@enzymefinance/protocol/contracts/lib/LibEnzymeFiat.sol";
import "@enzymefinance/protocol/contracts/lib/LibFarming.sol";
import "@enzymefinance/protocol/contracts/lib/LibMarket.sol";
import "@enzymefinance/protocol/contracts/lib/LibMetaData.sol";
import "@enzymefinance/protocol/contracts/lib/LibOptions.sol";
import "@enzymefinance/protocol/contracts/lib/LibOrchestrator.sol";
import "@enzymefinance/protocol/contracts/lib/LibOptionsMarket.sol";
import "@enzymefinance/protocol/contracts/lib/LibRevenue.sol";
import "@enzymefinance/protocol/contracts/lib/LibStorage.sol";
import "@enzymefinance/protocol/contracts/lib/LibToken.sol";
import "@enzymefinance/protocol/contracts/lib/LibWallet.sol";
import "@enzymefinance/protocol/contracts/utils/Utils.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./lib/LibAddressManager.sol";
import "./lib/LibBeacon.sol";
import "./lib/LibBudget.sol";
import "./lib/LibCrossChainOracle.sol";
import "./lib/LibEnzymeFiat.sol";
import "./lib/LibFarming.sol";
import "./lib/LibMarket.sol";
import "./lib/LibMetaData.sol";
import "./lib/LibPrice.sol";
import "./lib/LibSales.sol";
import "./lib/LibState.sol";
import "./lib/LibZKM.sol";
import "./lib/LibZeroExOracle.sol";
import "./IAddressManager.sol";
import "./ILiquidityPoolStaker.sol";
import "hardhat/console.sol";

contract EnzymeStrategyAgent is Ownable {
    using SafeMath for uint256;
    using MerkleProof for bytes32[];

    // Enzyme Protocol interfaces
    IEnzymeVault private enzymeVault;
    IEnzymeVaultMinter private enzymeVaultMinter;
    IEnzymeVaultStake private enzymeVaultStake;
    IEnzymeVaultStakeRewards private enzymeVaultStakeRewards;
    IEnzymeVaultZapper private enzymeVaultZapper;
    ICompoundV3Pool private compoundV3Pool;
    IAaveV2LendingPool private aaveV2LendingPool;
    IBalancerV2Pool private balancerV2Pool;
    ICurveLiquidityPool private curveLiquidityPool;

    // Utilities
    LibAddressManager private addressManager;
    LibOrchestrator private orchestrator;
    LibRevenue private revenue;
    LibBudget private budget;
    LibOptions private options;
    LibOptionsMarket private optionsMarket;
    LibMetaData private metaData;
    LibStorage private storage;
    LibToken private token;
    LibWallet private wallet;
    LibMarket private market;
    LibEnzymeFiat private enzymeFiat;
    LibCrossChainOracle private crossChainOracle;
    LibFarming private farming;

    constructor(
        address _addressManager,
        address _orchestrator,
        address _revenue,
        address _budget,
        address _options,
        address _optionsMarket,
        address _metaData,
        address _storage,
        address _token,
        address _wallet,
        address _market,
        address _enzymeFiat,
        address _crossChainOracle,
        address _farming
    ) {
        addressManager = LibAddressManager(_addressManager);
        orchestrator = LibOrchestrator(_orchestrator);
        revenue = LibRevenue(_revenue);
        budget = LibBudget(_budget);
        options = LibOptions(_options);
        optionsMarket = LibOptionsMarket(_optionsMarket);
        metaData = LibMetaData(_metaData);
        storage = LibStorage(_storage);
        token = LibToken(_token);
        wallet = LibWallet(_wallet);
        market = LibMarket(_market);
        enzymeFiat = LibEnzymeFiat(_enzymeFiat);
        crossChainOracle = LibCrossChainOracle(_crossChainOracle);
        farming = LibFarming(_farming);

        enzymeVault = IEnzymeVault(addressManager.getEnzymeVault());
        enzymeVaultMinter = IEnzymeVaultMinter(addressManager.getEnzymeVaultMinter());
        enzymeVaultStake = IEnzymeVaultStake(addressManager.getEnzymeVaultStake());
        enzymeVaultStakeRewards = IEnzymeVaultStakeRewards(addressManager.getEnzymeVaultStakeRewards());
        enzymeVaultZapper = IEnzymeVaultZapper(addressManager.getEnzymeVaultZapper());
        compoundV3Pool = ICompoundV3Pool(addressManager.getCompoundV3Pool());
        aaveV2LendingPool = IAaveV2LendingPool(addressManager.getAaveV2LendingPool());
        balancerV2Pool = IBalancerV2Pool(addressManager.getBalancerV2Pool());
        curveLiquidityPool = ICurveLiquidityPool(addressManager.getCurveLiquidityPool());
    }

    // Deposit functions
    function depositEnzymeVault(uint256 _amount) external onlyOwner {
        require(_amount > 0, "EnzymeStrategyAgent: Amount must be greater than 0");
        enzymeVaultMinter.deposit(address(this), _amount);
    }

    function depositEnzymeVault(uint256 _amount, address _beneficiary) external onlyOwner {
        require(_amount > 0, "EnzymeStrategyAgent: Amount must be greater than 0");
        enzymeVaultMinter.deposit(_beneficiary, _amount);
    }

    function depositEnzymeVault(uint256 _amount, uint256 _shares) external onlyOwner {
        require(_amount > 0, "EnzymeStrategyAgent: Amount must be greater than 0");
        require(_shares > 0, "EnzymeStrategyAgent: Shares must be greater than 0");
        enzymeVaultMinter.deposit(address(this), _amount, _shares);
    }

    function depositEnzymeVault(uint256 _amount, uint256 _shares, address _beneficiary) external onlyOwner {
        require(_amount > 0, "EnzymeStrategyAgent: Amount must be greater than 0");
        require(_shares > 0, "EnzymeStrategyAgent: Shares must be greater than 0");
        enzymeVaultMinter.deposit(_beneficiary, _amount, _shares);
    }

    // Withdraw functions
    function withdrawEnzymeVault(uint256 _shares) external onlyOwner {
        require(_shares > 0, "EnzymeStrategyAgent: Shares must be greater than 0");
        enzymeVaultMinter.withdraw(address(this), _shares);
    }

    function withdrawEnzymeVault(uint256 _shares, address _beneficiary) external onlyOwner {
        require(_shares > 0, "EnzymeStrategyAgent: Shares must be greater than 0");
        enzymeVaultMinter.withdraw(_beneficiary, _shares);
    }

    function withdrawEnzymeVault(uint256 _shares, uint256 _minAmount) external onlyOwner {
        require(_shares > 0, "EnzymeStrategyAgent: Shares must be greater than 0");
        require(_minAmount > 0, "EnzymeStrategyAgent: Min amount must be greater than 0");
        enzymeVaultMinter.withdraw(address(this), _shares, _minAmount);
    }

    function withdrawEnzymeVault(uint256 _shares, uint256 _minAmount, address _beneficiary) external onlyOwner {
        require(_shares > 0, "EnzymeStrategyAgent: Shares must be greater than 0");
        require(_minAmount > 0, "EnzymeStrategyAgent: Min amount must be greater than 0");
        enzymeVaultMinter.withdraw(_beneficiary, _shares, _minAmount);
    }

    // Stake functions
    function stakeEnzymeVault(uint256 _shares) external onlyOwner {
        require(_shares > 0, "EnzymeStrategyAgent: Shares must be greater than 0");
        enzymeVaultStake.stake(address(this), _shares);
    }

    function stakeEnzymeVault(uint256 _shares, address _beneficiary) external onlyOwner {
        require(_shares > 0, "EnzymeStrategyAgent: Shares must be greater than 0");
        enzymeVaultStake.stake(_beneficiary, _shares);
    }

    function stakeEnzymeVault(uint256 _shares, uint256 _minAmount) external onlyOwner {
        require(_shares > 0, "EnzymeStrategyAgent: Shares must be greater than 0");
        require(_minAmount > 0, "EnzymeStrategyAgent: Min amount must be greater than 0");
        enzymeVaultStake.stake(address(this), _shares, _minAmount);
    }

    function stakeEnzymeVault(uint256 _shares, uint256 _minAmount, address _beneficiary) external onlyOwner {
        require(_shares > 0, "EnzymeStrategyAgent: Shares must be greater than 0");
        require(_minAmount > 0, "EnzymeStrategyAgent: Min amount must be greater than 0");
        enzymeVaultStake.stake(_beneficiary, _shares, _minAmount);
    }

    // Withdraw stake functions
    function withdrawEnzymeVaultStake(uint256 _shares) external onlyOwner {
        require(_shares > 0, "EnzymeStrategyAgent: Shares must be greater than 0");
        enzymeVaultStake.withdraw(address(this), _shares);
    }

    function withdrawEnzymeVaultStake(uint256 _shares, address _beneficiary) external onlyOwner {
        require(_shares > 0, "EnzymeStrategyAgent: Shares must be greater than 0");
        enzymeVaultStake.withdraw(_beneficiary, _shares);
    }

    function withdrawEnzymeVaultStake(uint256 _shares, uint256 _minAmount) external onlyOwner {
        require(_shares > 0, "EnzymeStrategyAgent: Shares must be greater than 0");
        require(_minAmount > 0, "EnzymeStrategyAgent: Min amount must be greater than 0");
        enzymeVaultStake.withdraw(address(this), _shares, _minAmount);
    }

    function withdrawEnzymeVaultStake(uint256 _shares, uint256 _minAmount, address _beneficiary) external onlyOwner {
        require(_shares > 0, "EnzymeStrategyAgent: Shares must be greater than 0");
        require(_minAmount > 0, "EnzymeStrategyAgent: Min amount must be greater than 0");
        enzymeVaultStake.withdraw(_beneficiary, _shares, _minAmount);
    }

    // Collect functions
    function collectCompoundV3() external onlyOwner {
        address[] memory cTokens = addressManager.getCompoundV3CTokens();
        for (uint256 i = 0; i < cTokens.length; i++) {
            compoundV3Pool.claimComp(cTokens[i]);
        }
    }

    function collectAaveV2() external onlyOwner {
        address[] memory tokens = addressManager.getAaveV2Tokens();
        for (uint256 i = 0; i < tokens.length; i++) {
            aaveV2LendingPool.claimRewards(tokens[i], type(uint256).max, address(this));
        }
    }

    function collectBalancerV2() external onlyOwner {
        address[] memory tokens = addressManager.getBalancerV2Tokens();
        for (uint256 i = 0; i < tokens.length; i++) {
            balancerV2Pool.claimRewards(tokens[i], address(this));
        }
    }

    function collectCurveLiquidityPool() external onlyOwner {
        address[] memory tokens = addressManager.getCurveLiquidityPoolTokens();
        for (uint256 i = 0; i < tokens.length; i++) {
            curveLiquidityPool.claimRewards(tokens[i], address(this));
        }
    }

    function collectStakedBalancerV2() external onlyOwner {
        address[] memory tokens = addressManager.getStakedBalancerV2Tokens();
        for (uint256 i = 0; i < tokens.length; i++) {
            stakedBalancerV2Pool.claimRewards(tokens[i], address(this));
        }
    }

    function collectUniswapV2() external onlyOwner {
        address[] memory tokens = addressManager.getUniswapV2Tokens();
        for (uint256 i = 0; i < tokens.length; i++) {
            uniswapV2LiquidityPool.claimRewards(tokens[i], address(this));
        }
    }

    function collectYearnVault() external onlyOwner {
        address[] memory tokens = addressManager.getYearnVaultTokens();
        for (uint256 i = 0; i < tokens.length; i++) {
            yearnVault.claimRewards(tokens[i], address(this));
        }
    }

    function collectStakedYearnVault() external onlyOwner {
        address[] memory tokens = addressManager.getStakedYearnVaultTokens();
        for (uint256 i = 0; i < tokens.length; i++) {
            stakedYearnVault.claimRewards(tokens[i], address(this));
        }
    }

    function collectSushiSwap() external onlyOwner {
        address[] memory tokens = addressManager.getSushiSwapTokens();
        for (uint256 i = 0; i < tokens.length; i++) {
            sushiSwapPool.claimRewards(tokens[i], address(this));
        }
    }

    function collectAaveLiquidityPool() external onlyOwner {
        address[] memory tokens = addressManager.getAaveLiquidityPoolTokens();
        for (uint256 i = 0; i < tokens.length; i++) {
            aaveLiquidityPool.claimRewards(tokens[i], address(this));
        }
    }

    function collectLidoStaked() external onlyOwner {
        address[] memory tokens = addressManager.getLidoStakedTokens();
        for (uint256 i = 0; i < tokens.length; i++) {
            lidoStaked.claimRewards(tokens[i], address(this));
        }
    }

    function collectUbeVault() external onlyOwner {
        address[] memory tokens = addressManager.getUbeVaultTokens();
        for (uint256 i = 0; i < tokens.length; i++) {
            ubeVault.claimRewards(tokens[i], address(this));
        }
    }

    function collectPickleFinance() external onlyOwner {
        address[] memory tokens = addressManager.getPickleFinanceTokens();
        for (uint256 i = 0; i < tokens.length; i++) {
            pickleFinance.claimRewards(tokens[i], address(this));
        }
    }

    function collectUbeFarm() external onlyOwner {
        address[] memory tokens = addressManager.getUbeFarmTokens();
        for (uint256 i = 0; i < tokens.length; i++) {
            ubeFarm.claimRewards(tokens[i], address(this));
        }
    }

    function collectHarvestVault() external onlyOwner {
        address[] memory tokens = addressManager.getHarvestVaultTokens();
        for (uint256 i = 0; i < tokens.length; i++) {
            harvestVault.claimRewards(tokens[i], address(this));
        }
    }

    function collectFarm() external onlyOwner {
        address[] memory tokens = addressManager.getFarmTokens();
        for (uint256 i = 0; i < tokens.length; i++) {
            farm.claimRewards(tokens[i], address(this));
        }
    }

    function collectStakedFarm() external onlyOwner {
        address[] memory tokens = addressManager.getStakedFarmTokens();
        for (uint256 i = 0; i < tokens.length; i++) {
            stakedFarm.claimRewards(tokens[i], address(this));
        }
    }

    function collectStakedHarvestVault() external onlyOwner {
        address[] memory tokens = addressManager.getStakedHarvestVaultTokens();
        for (uint256 i = 0; i < tokens.length; i++) {
            stakedHarvestVault.claimRewards(tokens[i], address(this));
        }
    }

    function collectStakedUbeFarm() external onlyOwner {
        address[] memory tokens = addressManager.getStakedUbeFarmTokens();
        for (uint256 i = 0; i < tokens.length; i++) {
            stakedUbeFarm.claimRewards(tokens[i], address(this));
        }
    }

    function collectStakedPickleFinance() external onlyOwner {
        address[] memory tokens = addressManager.getStakedPickleFinanceTokens();
        for (uint256 i = 0; i < tokens.length; i++) {
            stakedPickleFinance.claimRewards(tokens[i], address(this));
        }
    }

    function collectStakedUbeVault() external onlyOwner {
        address[] memory tokens = addressManager.getStakedUbeVaultTokens();
        for (uint256 i = 0; i < tokens.length; i++) {
            stakedUbeVault.claimRewards(tokens[i], address(this));
        }
    }

    function collectStakedLido() external onlyOwner {
        address[] memory tokens = addressManager.getStakedLidoTokens();
        for (uint256 i = 0; i < tokens.length; i++) {
            stakedLido.claimRewards(tokens[i], address(this));
        }
    }

    function collectStakedAaveLiquidityPool() external onlyOwner {
        address[] memory tokens = addressManager.getStakedAaveLiquidityPoolTokens();
        for (uint256 i = 0; i < tokens.length; i++) {
            stakedAaveLiquidityPool.claimRewards(tokens[i], address(this));
        }
    }

    function collectStakedSushiSwap() external onlyOwner {
        address[] memory tokens = addressManager.getStakedSushiSwapTokens();
        for (uint256 i = 0; i < tokens.length; i++) {
            stakedSushiSwap.claimRewards(tokens[i], address(this));
        }
    }

    function collectStakedUniswapV2() external onlyOwner {
        address[] memory tokens = addressManager.getStakedUniswapV2Tokens();
        for (uint256 i = 0; i < tokens.length; i++) {
            stakedUniswapV2.claimRewards(tokens[i], address(this));
        }
    }

    function collectStakedYearnVault() external onlyOwner {
        address[] memory tokens = addressManager.getStakedYearnVaultTokens();
        for (uint256 i = 0; i < tokens.length; i++) {
            stakedYearnVault.claimRewards(tokens[i], address(this));
        }
    }

    function collectStakedBalancerV2() external onlyOwner {
        address[] memory tokens = addressManager.getStakedBalancerV2Tokens();
        for (uint256 i = 0; i < tokens.length; i++) {
            stakedBalancerV2Pool.claimRewards(tokens[i], address(this));
        }
    }

    function collectStakedCompoundV3() external onlyOwner {
        address[] memory tokens = addressManager.getStakedCompoundV3Tokens();
        for (uint256 i = 0; i < tokens.length; i++) {
            stakedCompoundV3.claimRewards(tokens[i], address(this));
        }
    }

    function collectStakedStakedAaveV2() external onlyOwner {
        address[] memory tokens = addressManager.getStakedStakedAaveV2Tokens();
        for (uint256 i = 0; i < tokens.length; i++) {
            stakedStakedAaveV2.claimRewards(tokens[i], address(this));
        }
    }

    function collectStakedIdle() external onlyOwner {
        address[] memory tokens = addressManager.getStakedIdleTokens();
        for (uint256 i = 0; i < tokens.length; i++) {
            stakedIdle.claimRewards(tokens[i], address(this));
        }
    }

    function collectStakedXusdV2() external onlyOwner {
        address[] memory tokens = addressManager.getStakedXusdV2Tokens();
        for (uint256 i = 0; i < tokens.length; i++) {
            stakedXusdV2.claimRewards(tokens[i], address(this));
        }
    }

    function collectStakedUbeLeverageVault() external onlyOwner {
        address[] memory tokens = addressManager.getStakedUbeLeverageVaultTokens();
        for (uint256 i = 0; i < tokens.length; i++) {
            stakedUbeLeverageVault.claimRewards(tokens[i], address(this));
        }
    }

    function collectStakedLpCompound() external onlyOwner {
        address[] memory tokens = addressManager.getStakedLpCompoundTokens();
        for (uint256 i = 0; i < tokens.length; i++) {
            stakedLpCompound.claimRewards(tokens[i], address(this));
        }
    }

    function collectStakedLpStakedAaveV2() external onlyOwner {
        address[] memory tokens = addressManager.getStakedLpStakedAaveV2Tokens();
        for (uint256 i = 0; i < tokens.length; i++) {
            stakedLpStakedAaveV2.claimRewards(tokens[i], address(this));
        }
    }

    function collectStakedLpBalancerV2() external onlyOwner {
        address[] memory tokens = addressManager.getStakedLpBalancerV2Tokens();
        for (uint256 i = 0; i < tokens.length; i++) {
            stakedLpBalancerV2.claimRewards(tokens[i], address(this));
        }
    }

    function collectStakedLpPickleFinance() external onlyOwner {
        address[] memory tokens = addressManager.getStakedLpPickleFinanceTokens();
        for (uint256 i = 0; i < tokens.length; i++) {
            stakedLpPickleFinance.claimRewards(tokens[i], address(this));
        }
    }

    function collectStakedLpSushiSwap() external onlyOwner {
        address[] memory tokens = addressManager.getStakedLpSushiSwapTokens();
        for (uint256 i = 0; i < tokens.length; i++) {
            stakedLpSushiSwap.claimRewards(tokens[i], address(this));
        }
    }

    function collectStakedLpUbeVault() external onlyOwner {
        address[] memory tokens = addressManager.getStakedLpUbeVaultTokens();
        for (uint256 i = 0; i < tokens.length; i++) {
            stakedLpUbeVault.claimRewards(tokens[i], address(this));
        }
    }

    function collectStakedLpYearnVault() external onlyOwner {
        address[] memory tokens = addressManager.getStakedLpYearnVaultTokens();
        for(uint256 i = 0; i < tokens.length; i++) {
            stakedLpYearnVault.claimRewards(tokens[i], address(this));
        }
    }

    function collectStakedLpHarvestVault() external onlyOwner {
        address[] memory tokens = addressManager.getStakedLpHarvestVaultTokens();
        for (uint256 i = 0; i < tokens.length; i++) {
            stakedLpHarvestVault.claimRewards(tokens[i], address(this));
        }
    }

    function collectStakedLpFarm() external onlyOwner {
        address[] memory tokens = addressManager.getStakedLpFarmTokens();
        for (uint256 i = 0; i < tokens.length; i++) {
            stakedLpFarm.claimRewards(tokens[i], address(this));
        }
    }

    function collectStakedLpStakedHarvestVault() external onlyOwner {
        address[] memory tokens = addressManager.getStakedLpStakedHarvestVaultTokens();
        for (uint256 i = 0; i < tokens.length; i++) {
            stakedLpStakedHarvestVault.claimRewards(tokens[i], address(this));
        }
    }

    function collectStakedLpStakedUbeFarm() external onlyOwner {
        address[] memory tokens = addressManager.getStakedLpStakedUbeFarmTokens();
        for (uint256 i = 0; i < tokens.length; i++) {
            stakedLpStakedUbeFarm.claimRewards(tokens[i], address(this));
        }
    }

    function collectStakedLpStakedPickleFinance() external onlyOwner {
        address[] memory tokens = addressManager.getStakedLpStakedPickleFinanceTokens();
        for (uint256 i = 0; i < tokens.length; i++) {
            stakedLpStakedPickleFinance.claimRewards(tokens[i], address(this));
        }
    }

    function collectStakedLpStakedUbeVault() external onlyOwner {
        address[] memory tokens = addressManager.getStakedLpStakedUbeVaultTokens();
        for (uint256 i = 0; i < tokens.length; i++) {
            stakedLpStakedUbeVault.claimRewards(tokens[i], address(this));
        }
    }

    function collectStakedLpStakedLido() external onlyOwner {
        address[] memory tokens = addressManager.getStakedLpStakedLidoTokens();
        for (uint256 i = 0; i < tokens.length; i++) {
            stakedLpStakedLido.claimRewards(tokens[i], address(this));
        }
    }

    function collectStakedLpStakedAaveLiquidityPool() external onlyOwner {
        address[] memory tokens = addressManager.getStakedLpStakedAaveLiquidityPoolTokens();
        for (uint256 i = 0; i < tokens.length; i++) {
            stakedLpStakedAaveLiquidityPool.claimRewards(tokens[i], address(this));
        }
    }

    function collectStakedLpStakedSushiSwap() external onlyOwner {
        address[] memory tokens = addressManager.getStakedLpStakedSushiSwapTokens();
        for (uint256 i = 0; i < tokens.length; i++) {
            stakedLpStakedSushiSwap.claimRewards(tokens[i], address(this));
        }
    }

    function collectStakedLpStakedUniswapV2() external onlyOwner {
        address[] memory tokens = addressManager.getStakedLpStakedUniswapV2Tokens();
        for (uint256 i = 0; i < tokens.length; i++) {
            stakedLpStakedUniswapV2.claimRewards(tokens[i], address(this));
        }
    }

    function collectStakedLpStakedYearnVault() external onlyOwner {
        address[] memory tokens = addressManager.getStakedLpStakedYearnVaultTokens();
        for (uint256 i = 0; i < tokens.length; i++) {
            stakedLpStakedYearnVault.claimRewards(tokens[i], address(this));
        }
    }

    function collectStakedLpStakedBalancerV2() external onlyOwner {
        address[] memory tokens = addressManager.getStakedLpStakedBalancerV2Tokens();
        for (uint256 i = 0; i < tokens.length; i++) {
            stakedLpStakedBalancerV2.claimRewards(tokens[i], address(this));
        }
    }

    function collectStakedLpStakedCompoundV3() external onlyOwner {
        address[] memory tokens = addressManager.getStakedLpStakedCompoundV3Tokens();
        for (uint256 i = 0; i < tokens.length; i++) {
            stakedLpStakedCompoundV3.claimRewards(tokens[i], address(this));
        }
    }

    function collectStakedLpStakedStakedAaveV2() external onlyOwner {
        address[] memory tokens = addressManager.getStakedLpStakedStakedAaveV2Tokens();
        for (uint256 i = 0; i < tokens.length; i++) {
            stakedLpStakedStakedAaveV2.claimRewards(tokens[i], address(this));
        }
    }

    function collectStakedLpStakedIdle() external onlyOwner {
        address[] memory tokens = addressManager.getStakedLpStakedIdleTokens();
        for (uint256 i = 0; i < tokens.length; i++) {
            stakedLpStakedIdle.claimRewards(tokens[i], address(this));
        }
    }

    function collectStakedLpStakedXusdV2() external onlyOwner {
        address[] memory tokens = addressManager.getStakedLpStakedXusdV2Tokens();
        for (uint256 i = 0; i < tokens.length; i++) {
            stakedLpStakedXusdV2.claimRewards(tokens[i], address(this));
        }
    }

    function collectStakedLpStakedUbeLeverageVault() external onlyOwner {
        address[] memory tokens = addressManager.getStakedLpStakedUbeLeverageVaultTokens();
        for (uint256 i = 0; i < tokens.length; i++) {
            stakedLpStakedUbeLeverageVault.claimRewards(tokens[i], address(this));
        }
    }

    function collectStakedLpStakedLpCompound() external onlyOwner {
        address[] memory tokens = addressManager.getStakedLpStakedLpCompoundTokens();
        for (uint256 i = 0; i < tokens.length; i++) {
            stakedLpStakedLpCompound.claimRewards(tokens[i], address(this));
        }
    }
    contract StrategyAgent is ReentrancyGuard {
    IAddressManager public addressManager;

    constructor(address _addressManager) {
        addressManager = IAddressManager(_addressManager);
    }

    modifier gasLimit(uint256 gas) {
        require(gasleft() >= gas, "Insufficient gas");
        _;
    }

    function collectRewards() external onlyOwner nonReentrant gasLimit(200000) {
        collectStakedLpStakedLpAaveV2();
        collectStakedLpStakedLpAaveV2StableDebt();
        collectStakedLpStakedLpAaveV2VariableDebt();
        collectStakedLpStakedLpAaveV3();
        collectStakedLpStakedLpAaveV3StableDebt();
        collectStakedLpStakedLpAaveV3VariableDebt();
    }

    function collectStakedLpStakedLpAaveV2() private {
        address[] memory tokens = addressManager.getStakedLpStakedLpAaveV2Tokens();
        for (uint256 i = 0; i < tokens.length; i++) {
            address poolStakerAddress = addressManager.getStakedLpStakedLpAaveV2StakerAddress(tokens[i]);
            ILiquidityPoolStaker(poolStakerAddress).claimRewards(tokens[i], address(this));
        }
    }

    function collectStakedLpStakedLpAaveV2StableDebt() private {
        address[] memory tokens = addressManager.getStakedLpStakedLpAaveV2StableDebtTokens();
        for (uint256 i = 0; i < tokens.length; i++) {
            address poolStakerAddress = addressManager.getStakedLpStakedLpAaveV2StableDebtStakerAddress(tokens[i]);
            ILiquidityPoolStaker(poolStakerAddress).claimRewards(tokens[i], address(this));
        }
    }

    function collectStakedLpStakedLpAaveV2VariableDebt() private {
        address[] memory tokens = addressManager.getStakedLpStakedLpAaveV2VariableDebtTokens();
        for (uint256 i = 0; i < tokens.length; i++) {
            address poolStakerAddress = addressManager.getStakedLpStakedLpAaveV2VariableDebtStakerAddress(tokens[i]);
            ILiquidityPoolStaker(poolStakerAddress).claimRewards(tokens[i], address(this));
        }
    }

    function collectStakedLpStakedLpAaveV3() private {
        address[] memory tokens = addressManager.getStakedLpStakedLpAaveV3Tokens();
        for (uint256 i = 0; i < tokens.length; i++) {
            address poolStakerAddress = addressManager.getStakedLpStakedLpAaveV3StakerAddress(tokens[i]);
            ILiquidityPoolStaker(poolStakerAddress).claimRewards(tokens[i], address(this));
        }
    }

    function collectStakedLpStakedLpAaveV3StableDebt() private {
        address[] memory tokens = addressManager.getStakedLpStakedLpAaveV3StableDebtTokens();
        for (uint256 i = 0; i < tokens.length; i++) {
            address poolStakerAddress = addressManager.getStakedLpStakedLpAaveV3StableDebtStakerAddress(tokens[i]);
            ILiquidityPoolStaker(poolStakerAddress).claimRewards(tokens[i], address(this));
        }
    }

    function collectStakedLpStakedLpAaveV3VariableDebt() private {
        address[] memory tokens = addressManager.getStakedLpStakedLpAaveV3VariableDebtTokens();
        for (uint256 i = 0; i < tokens.length; i++) {
            address poolStakerAddress = addressManager.getStakedLpStakedLpAaveV3VariableDebtStakerAddress(tokens[i]);
            ILiquidityPoolStaker(poolStakerAddress).claimRewards(tokens[i], address(this));
        }
    }
}
   // Fallback function to reject any Ether sent to the contract
    receive() external payable {
        revert("EnzymeStrategyAgent: Ether not accepted");
    }

    // Function to withdraw any accidentally sent ERC20 tokens
    function withdrawERC20(address _token, address _to, uint256 _amount) external onlyOwner {
        require(_token != address(0), "EnzymeStrategyAgent: Invalid token address");
        require(_to != address(0), "EnzymeStrategyAgent: Invalid recipient address");
        require(_amount > 0, "EnzymeStrategyAgent: Amount must be greater than 0");

        require(IERC20(_token).transfer(_to, _amount), "EnzymeStrategyAgent: Transfer failed");
    }

    // Function to withdraw any accidentally sent Ether
    function withdrawEther(address payable _to, uint256 _amount) external onlyOwner {
        require(_to != address(0), "EnzymeStrategyAgent: Invalid recipient address");
        require(_amount > 0, "EnzymeStrategyAgent: Amount must be greater than 0");

        _to.transfer(_amount);
    }
}
    
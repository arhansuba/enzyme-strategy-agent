pragma solidity ^0.8.0;

interface IEnzymeStrategyAgent {
    function depositEnzymeVault(uint256 _amount) external;
    function depositEnzymeVault(uint256 _amount, address _beneficiary) external;
    function depositEnzymeVault(uint256 _amount, uint256 _shares) external;
    function depositEnzymeVault(uint256 _amount, uint256 _shares, address _beneficiary) external;

    function withdrawEnzymeVault(uint256 _shares) external;
    function withdrawEnzymeVault(uint256 _shares, address _beneficiary) external;
    function withdrawEnzymeVault(uint256 _shares, uint256 _minAmount) external;
    function withdrawEnzymeVault(uint256 _shares, uint256 _minAmount, address _beneficiary) external;

    function stakeEnzymeVault(uint256 _shares) external;
    function stakeEnzymeVault(uint256 _shares, address _beneficiary) external;
    function stakeEnzymeVault(uint256 _shares, uint256 _minAmount) external;
    function stakeEnzymeVault(uint256 _shares, uint256 _minAmount, address _beneficiary) external;

    function withdrawEnzymeVaultStake(uint256 _shares) external;
    function withdrawEnzymeVaultStake(uint256 _shares, address _beneficiary) external;
    function withdrawEnzymeVaultStake(uint256 _shares, uint256 _minAmount) external;
    function withdrawEnzymeVaultStake(uint256 _shares, uint256 _minAmount, address _beneficiary) external;

    function collectCompoundV3() external;
    function collectAaveV2() external;

    function onZKMLPredictions(bytes32[] memory _predictions) external;
}

contract EnzymeStrategyAgent is IEnzymeStrategyAgent {
    IEnzymeVault public enzymeVault;
    IERC20 public enzymeToken;
    IZKMLOracle public zkmlOracle;

    constructor(address _enzymeVault, address _enzymeToken, address _zkmlOracle) {
        enzymeVault = IEnzymeVault(_enzymeVault);
        enzymeToken = IERC20(_enzymeToken);
        zkmlOracle = IZKMLOracle(_zkmlOracle);
    }

    // ... other functions that interact with the enzymeVault and zkmlOracle contracts ...

    function onZKMLPredictions(bytes32[] memory _predictions) external override {
        // Handle the received predictions based on your strategy logic
    }
}
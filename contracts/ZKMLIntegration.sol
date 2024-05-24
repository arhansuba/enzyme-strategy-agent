pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./IEnzymeStrategyAgent.sol";
import "./IZKMLOracle.sol";

contract ZKMLIntegration is Ownable {
    using SafeMath for uint256;

    IEnzymeStrategyAgent public strategyAgent;
    IZKMLOracle public zkmlOracle;

    uint256 public constant ZKML_FEE = 1000000000000000000; // 0.1 ETH

    constructor(IEnzymeStrategyAgent _strategyAgent, IZKMLOracle _zkmlOracle) {
        strategyAgent = _strategyAgent;
        zkmlOracle = _zkmlOracle;
    }

    function predict(bytes32[] calldata encryptedData) external onlyOwner {
        require(encryptedData.length > 0, "ZKMLIntegration: Encrypted data array cannot be empty");

        uint256 fee = ZKML_FEE.mul(encryptedData.length);
        require(msg.value >= fee, "ZKMLIntegration: Insufficient Ether provided");

        bytes32[] memory predictions = new bytes32[](encryptedData.length);

        for (uint256 i = 0; i < encryptedData.length; i++) {
            predictions[i] = zkmlOracle.predict(encryptedData[i]);
        }

        strategyAgent.onZKMLPredictions(predictions);

        transferOwnership(strategyAgent);
    }

    function updateZKMLOracle(IZKMLOracle _zkmlOracle) external onlyOwner {
        zkmlOracle = _zkmlOracle;
    }

    function transferOwnership(address newOwner) external onlyOwner {
        _transferOwnership(newOwner);
    }
}

contract IZKMLOracle is interface {
    function predict(bytes32 encryptedData) external view returns (bytes32);
}
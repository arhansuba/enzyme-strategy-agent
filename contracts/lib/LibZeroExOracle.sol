// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces/IOracle.sol";

library LibZeroExOracle {
    struct ZeroExOracle {
        IOracle oracle;
        uint256 feePercentage;
    }

    event OracleSet(address indexed oracle);
    event FeePercentageSet(uint256 feePercentage);

    function setOracle(ZeroExOracle storage self, IOracle _oracle) internal {
        require(address(_oracle) != address(0), "Invalid oracle address");
        self.oracle = _oracle;
        emit OracleSet(address(_oracle));
    }

    function setFeePercentage(ZeroExOracle storage self, uint256 _feePercentage) internal {
        require(_feePercentage <= 100, "Invalid fee percentage");
        self.feePercentage = _feePercentage;
        emit FeePercentageSet(_feePercentage);
    }

    function getOracle(ZeroExOracle storage self) internal view returns (IOracle) {
        return self.oracle;
    }

    function getFeePercentage(ZeroExOracle storage self) internal view returns (uint256) {
        return self.feePercentage;
    }
}

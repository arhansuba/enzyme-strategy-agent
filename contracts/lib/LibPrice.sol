// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

library LibPrice {
    struct Price {
        uint256 value;
        uint256 timestamp;
    }

    event PriceUpdated(uint256 value, uint256 timestamp);

    function initialize(Price storage self, uint256 _value, uint256 _timestamp) internal {
        self.value = _value;
        self.timestamp = _timestamp;
        emit PriceUpdated(_value, _timestamp);
    }

    function updatePrice(Price storage self, uint256 _value, uint256 _timestamp) internal {
        self.value = _value;
        self.timestamp = _timestamp;
        emit PriceUpdated(_value, _timestamp);
    }

    function getValue(Price storage self) internal view returns (uint256) {
        return self.value;
    }

    function getTimestamp(Price storage self) internal view returns (uint256) {
        return self.timestamp;
    }
}

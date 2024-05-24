// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

library LibCrossChainOracle {
    struct CrossChainOracle {
        mapping(address => AggregatorV3Interface) priceFeeds;
        address owner;
    }

    event PriceFeedAdded(address indexed asset, address indexed aggregator);

    function initialize(CrossChainOracle storage self, address _owner) internal {
        require(_owner != address(0), "Owner address cannot be zero");
        self.owner = _owner;
    }

    function addPriceFeed(CrossChainOracle storage self, address _asset, address _aggregator) internal {
        require(_asset != address(0), "Asset address cannot be zero");
        require(_aggregator != address(0), "Aggregator address cannot be zero");
        require(self.priceFeeds[_asset] == AggregatorV3Interface(address(0)), "Price feed already exists");

        self.priceFeeds[_asset] = AggregatorV3Interface(_aggregator);
        emit PriceFeedAdded(_asset, _aggregator);
    }

    function getPriceFeed(CrossChainOracle storage self, address _asset) internal view returns (AggregatorV3Interface) {
        return self.priceFeeds[_asset];
    }

    function getOwner(CrossChainOracle storage self) internal view returns (address) {
        return self.owner;
    }
}

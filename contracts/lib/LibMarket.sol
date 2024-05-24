// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

library LibMarket {
    struct Market {
        mapping(address => uint256) prices;
        address owner;
        IERC20 token;
    }

    event PriceUpdated(address indexed token, uint256 price);

    function initialize(Market storage self, address _owner, address _token) internal {
        require(_owner != address(0), "Owner address cannot be zero");
        require(_token != address(0), "Token address cannot be zero");
        self.owner = _owner;
        self.token = IERC20(_token);
    }

    function updatePrice(Market storage self, address _token, uint256 _price) internal {
        require(_token != address(0), "Token address cannot be zero");
        require(_price > 0, "Price must be greater than zero");
        self.prices[_token] = _price;
        emit PriceUpdated(_token, _price);
    }

    function getPrice(Market storage self, address _token) internal view returns (uint256) {
        return self.prices[_token];
    }

    function getOwner(Market storage self) internal view returns (address) {
        return self.owner;
    }

    function getToken(Market storage self) internal view returns (IERC20) {
        return self.token;
    }
}

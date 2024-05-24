// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

library LibEnzymeFiat {
    struct EnzymeFiat {
        mapping(address => uint256) fiatBalances;
        address owner;
    }

    event FiatBalanceAdded(address indexed user, uint256 amount);
    event FiatBalanceRemoved(address indexed user, uint256 amount);

    function initialize(EnzymeFiat storage self, address _owner) internal {
        require(_owner != address(0), "Owner address cannot be zero");
        self.owner = _owner;
    }

    function addFiatBalance(EnzymeFiat storage self, address _user, uint256 _amount) internal {
        require(_user != address(0), "User address cannot be zero");
        self.fiatBalances[_user] += _amount;
        emit FiatBalanceAdded(_user, _amount);
    }

    function removeFiatBalance(EnzymeFiat storage self, address _user, uint256 _amount) internal {
        require(_user != address(0), "User address cannot be zero");
        require(self.fiatBalances[_user] >= _amount, "Insufficient balance");
        self.fiatBalances[_user] -= _amount;
        emit FiatBalanceRemoved(_user, _amount);
    }

    function getFiatBalance(EnzymeFiat storage self, address _user) internal view returns (uint256) {
        return self.fiatBalances[_user];
    }

    function getOwner(EnzymeFiat storage self) internal view returns (address) {
        return self.owner;
    }
}

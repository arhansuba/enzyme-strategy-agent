// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library LibBudget {
    struct Budget {
        mapping(address => uint256) allocations;
        uint256 totalBudget;
    }

    event BudgetAllocated(address indexed recipient, uint256 amount);
    event BudgetSpent(address indexed recipient, uint256 amount);

    function initialize(Budget storage _budget, uint256 _initialBudget) internal {
        _budget.totalBudget = _initialBudget;
    }

    function allocate(Budget storage _budget, address _recipient, uint256 _amount) internal {
        require(_amount > 0, "Amount must be greater than zero");
        require(_budget.totalBudget >= _amount, "Insufficient budget");

        _budget.allocations[_recipient] += _amount;
        _budget.totalBudget -= _amount;

        emit BudgetAllocated(_recipient, _amount);
    }

    function spend(Budget storage _budget, address _recipient, uint256 _amount) internal {
        require(_amount > 0, "Amount must be greater than zero");
        require(_budget.allocations[_recipient] >= _amount, "Insufficient allocation");

        _budget.allocations[_recipient] -= _amount;
        _budget.totalBudget += _amount;

        emit BudgetSpent(_recipient, _amount);
    }

    function getAllocation(Budget storage _budget, address _recipient) internal view returns (uint256) {
        return _budget.allocations[_recipient];
    }

    function getTotalBudget(Budget storage _budget) internal view returns (uint256) {
        return _budget.totalBudget;
    }
}

from typing import Dict

class LibBudget:
    def __init__(self, initial_budget: int) -> None:
        self.allocations: Dict[str, int] = {}
        self.total_budget = initial_budget

    def allocate(self, recipient: str, amount: int) -> None:
        assert amount > 0, "Amount must be greater than zero"
        assert self.total_budget >= amount, "Insufficient budget"
        
        self.allocations[recipient] = self.allocations.get(recipient, 0) + amount
        self.total_budget -= amount

    def spend(self, recipient: str, amount: int) -> None:
        assert amount > 0, "Amount must be greater than zero"
        assert recipient in self.allocations, "Recipient has no allocation"
        assert self.allocations[recipient] >= amount, "Insufficient allocation"
        
        self.allocations[recipient] -= amount
        self.total_budget += amount

    def get_allocation(self, recipient: str) -> int:
        return self.allocations.get(recipient, 0)

    def get_total_budget(self) -> int:
        return self.total_budget

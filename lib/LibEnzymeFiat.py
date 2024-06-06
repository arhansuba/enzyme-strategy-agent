from typing import Dict

class LibEnzymeFiat:
    def __init__(self, owner: str) -> None:
        self.fiat_balances: Dict[str, int] = {}
        self.owner = owner

    def add_fiat_balance(self, user: str, amount: int) -> None:
        assert user != "0x0", "User address cannot be zero"
        self.fiat_balances[user] = self.fiat_balances.get(user, 0) + amount
        print(f"Fiat balance added for user {user}: {amount}")

    def remove_fiat_balance(self, user: str, amount: int) -> None:
        assert user != "0x0", "User address cannot be zero"
        assert user in self.fiat_balances, "User has no fiat balance"
        assert self.fiat_balances[user] >= amount, "Insufficient balance"
        self.fiat_balances[user] -= amount
        print(f"Fiat balance removed for user {user}: {amount}")

    def get_fiat_balance(self, user: str) -> int:
        return self.fiat_balances.get(user, 0)

    def get_owner(self) -> str:
        return self.owner

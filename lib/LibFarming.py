from typing import Dict
from typing_extensions import TypedDict
from eth_typing import ChecksumAddress

class Farming(TypedDict):
    stakedAmounts: Dict[ChecksumAddress, int]
    rewardsEarned: Dict[ChecksumAddress, int]
    owner: ChecksumAddress
    token: ChecksumAddress

def initialize(self: Farming, owner: ChecksumAddress, token: ChecksumAddress) -> None:
    assert owner != "0x0", "Owner address cannot be zero"
    assert token != "0x0", "Token address cannot be zero"
    self["owner"] = owner
    self["token"] = token

def stake(self: Farming, user: ChecksumAddress, amount: int) -> None:
    assert user != "0x0", "User address cannot be zero"
    assert amount > 0, "Staking amount must be greater than zero"
    self["stakedAmounts"][user] = self["stakedAmounts"].get(user, 0) + amount
    print(f"Staked {amount} for user {user}")

def unstake(self: Farming, user: ChecksumAddress, amount: int) -> None:
    assert user != "0x0", "User address cannot be zero"
    assert amount > 0, "Unstaking amount must be greater than zero"
    assert user in self["stakedAmounts"], "User has no staked amount"
    assert self["stakedAmounts"][user] >= amount, "Insufficient staked amount"
    self["stakedAmounts"][user] -= amount
    print(f"Unstaked {amount} for user {user}")

def claim_reward(self: Farming, user: ChecksumAddress, amount: int) -> None:
    assert user != "0x0", "User address cannot be zero"
    assert amount > 0, "Claimed amount must be greater than zero"
    self["rewardsEarned"][user] = self["rewardsEarned"].get(user, 0) + amount
    print(f"Claimed reward of {amount} for user {user}")

def get_staked_amount(self: Farming, user: ChecksumAddress) -> int:
    return self["stakedAmounts"].get(user, 0)

def get_rewards_earned(self: Farming, user: ChecksumAddress) -> int:
    return self["rewardsEarned"].get(user, 0)

def get_owner(self: Farming) -> ChecksumAddress:
    return self["owner"]

def get_token(self: Farming) -> ChecksumAddress:
    return self["token"]

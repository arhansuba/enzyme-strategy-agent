


from giza.agents import Contract

class EnzymeVaultInterface:
    def __init__(self, vault_minter, vault_stake, vault_zapper, vault_rewards, vault_staking_rewards, owner):
        self.vault_minter = Contract.from_abi("IEnzymeVaultMinter", vault_minter, [])
        self.vault_stake = Contract.from_abi("IEnzymeVaultStake", vault_stake, [])
        self.vault_zapper = Contract.from_abi("IEnzymeVaultZapper", vault_zapper, [])
        self.vault_rewards = Contract.from_abi("IEnzymeVaultRewards", vault_rewards, [])
        self.vault_staking_rewards = Contract.from_abi("IEnzymeVaultStakingRewards", vault_staking_rewards, [])
        self.owner = owner


    def deposit(self, recipient: str, amount: int, shares: int) -> None:
        assert self.owner == self.owner, "Only the owner can deposit"
        self.vault_zapper.deposit(recipient, amount, shares)

    def withdraw(self, recipient: str, shares: int, min_amount: int) -> None:
        assert self.owner == self.owner, "Only the owner can withdraw"
        self.vault_zapper.withdraw(recipient, shares, min_amount)

    def stake(self, recipient: str, shares: int, min_amount: int) -> None:
        assert self.owner == self.owner, "Only the owner can stake"
        self.vault_stake.stake(recipient, shares, min_amount)

    def unstake(self, recipient: str, shares: int) -> None:
        assert self.owner == self.owner, "Only the owner can unstake"
        self.vault_stake.unstake(recipient, shares)

    def claim_rewards(self, recipient: str) -> None:
        assert self.owner == self.owner, "Only the owner can claim rewards"
        reward_amount = self.vault_rewards.getReward(recipient)
        staking_reward_amount = self.vault_staking_rewards.getStakingReward(recipient)
        assert reward_amount > 0 or staking_reward_amount > 0, "No rewards to claim"
        if reward_amount > 0:
            self.vault_rewards.transfer(recipient, reward_amount)
        if staking_reward_amount > 0:
            self.vault_staking_rewards.transfer(recipient, staking_reward_amount)

    def get_shares(self, account: str) -> int:
        return self.vault_stake.balanceOf(account)

    def get_total_shares(self) -> int:
        return self.vault_stake.totalSupply()

    def get_total_assets(self) -> int:
        return self.vault_minter.totalSupply()

    def get_price_per_share(self) -> int:
        total_assets = self.get_total_assets()
        total_shares = self.get_total_shares()
        if total_assets == 0 or total_shares == 0:
            return 0
        return total_assets // total_shares

    def get_reward_rate(self) -> int:
        return self.vault_rewards.getRewardRate()

    def get_staking_reward_rate(self) -> int:
        return self.vault_staking_rewards.getStakingRewardRate()

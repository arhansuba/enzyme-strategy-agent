# SPDX-License-Identifier: MIT

from brownie import Contract, accounts

class EnzymeVaultController:
    def __init__(self, vaultMinter_addr, vaultStake_addr, vaultZapper_addr, vaultRewards_addr, vaultStakingRewards_addr):
        self.vaultMinter = Contract.from_abi("VaultMinter", vaultMinter_addr, abi=["deposit", "totalSupply", "getPricePerShare"])
        self.vaultStake = Contract.from_abi("VaultStake", vaultStake_addr, abi=["stake", "unstake", "balanceOf", "totalSupply"])
        self.vaultZapper = Contract.from_abi("VaultZapper", vaultZapper_addr, abi=["deposit", "withdraw"])
        self.vaultRewards = Contract.from_abi("VaultRewards", vaultRewards_addr, abi=["getReward", "transfer"])
        self.vaultStakingRewards = Contract.from_abi("VaultStakingRewards", vaultStakingRewards_addr, abi=["getStakingReward", "transfer"])

    def deposit(self, recipient, amount, shares):
        self.vaultZapper.deposit(recipient, amount, shares, {'from': accounts[0]})

    def withdraw(self, recipient, shares, minAmount):
        self.vaultZapper.withdraw(recipient, shares, minAmount, {'from': accounts[0]})

    def stake(self, recipient, shares, minAmount):
        self.vaultStake.stake(recipient, shares, minAmount, {'from': accounts[0]})

    def unstake(self, recipient, shares):
        self.vaultStake.unstake(recipient, shares, {'from': accounts[0]})

    def claim_rewards(self, recipient):
        rewardAmount = self.vaultRewards.getReward(recipient)
        stakingRewardAmount = self.vaultStakingRewards.getStakingReward(recipient)
        if rewardAmount > 0:
            self.vaultRewards.transfer(recipient, rewardAmount, {'from': accounts[0]})
        if stakingRewardAmount > 0:
            self.vaultStakingRewards.transfer(recipient, stakingRewardAmount, {'from': accounts[0]})

    def get_shares(self, account):
        return self.vaultStake.balanceOf(account)

    def get_total_shares(self):
        return self.vaultStake.totalSupply()

    def get_total_assets(self):
        return self.vaultMinter.totalSupply()

    def get_price_per_share(self):
        return self.vaultMinter.getPricePerShare()

from typing import Dict
from brownie import LibAddressManager, Contract

class LibBeacon:
    def __init__(self, admin: str) -> None:
        self.implementations: Dict[str, str] = {}
        self.contracts: Dict[str, str] = {}
        self.addressManager = LibAddressManager.AddressManager()
        self.admin = admin

    def register_implementation(self, name: str, implementation: str) -> None:
        assert implementation != "0x", "Implementation address cannot be zero"
        assert name not in self.implementations, "Implementation already registered"
        self.implementations[name] = implementation

    def register_contract(self, name: str, contract_address: str) -> None:
        assert contract_address != "0x", "Contract address cannot be zero"
        assert name not in self.contracts, "Contract already registered"
        self.contracts[name] = contract_address
        self.addressManager.add_address(contract_address)

    def upgrade_implementation(self, name: str, new_implementation: str) -> None:
        assert new_implementation != "0x", "New implementation address cannot be zero"
        assert name in self.implementations, "Implementation not registered"
        self.implementations[name] = new_implementation

    def change_admin(self, new_admin: str) -> None:
        assert new_admin != "0x", "New admin address cannot be zero"
        assert self.admin == Contract("Admin").owner(), "Only admin can change admin"
        self.admin = new_admin

    def get_implementation(self, name: str) -> str:
        return self.implementations.get(name, "")

    def get_contract(self, name: str) -> str:
        return self.contracts.get(name, "")

    def get_address_manager(self) -> LibAddressManager.AddressManager:
        return self.addressManager

    def get_admin(self) -> str:
        return self.admin

from typing_extensions import TypedDict
from eth_typing import ChecksumAddress
from brownie import interface

class Market(TypedDict):
    prices: dict
    owner: ChecksumAddress
    token: ChecksumAddress

def initialize(self: Market, owner: ChecksumAddress, token: ChecksumAddress) -> None:
    assert owner != "0x0", "Owner address cannot be zero"
    assert token != "0x0", "Token address cannot be zero"
    self["owner"] = owner
    self["token"] = token

def update_price(self: Market, token: ChecksumAddress, price: int) -> None:
    assert token != "0x0", "Token address cannot be zero"
    assert price > 0, "Price must be greater than zero"
    self["prices"][token] = price
    print(f"Price updated for token {token}: {price}")

def get_price(self: Market, token: ChecksumAddress) -> int:
    return self["prices"].get(token, 0)

def get_owner(self: Market) -> ChecksumAddress:
    return self["owner"]

def get_token(self: Market) -> ChecksumAddress:
    return self["token"]

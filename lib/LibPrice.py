from typing import Dict

class Price:
    def __init__(self, value: int, timestamp: int):
        self.value = value
        self.timestamp = timestamp

def initialize(self: Price, _value: int, _timestamp: int) -> None:
    self.value = _value
    self.timestamp = _timestamp
    print("Price initialized")

def update_price(self: Price, _value: int, _timestamp: int) -> None:
    self.value = _value
    self.timestamp = _timestamp
    print("Price updated")

def get_value(self: Price) -> int:
    return self.value

def get_timestamp(self: Price) -> int:
    return self.timestamp

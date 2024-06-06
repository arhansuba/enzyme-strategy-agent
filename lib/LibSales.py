class Sale:
    def __init__(self, seller: str, price: int, is_active: bool):
        self.seller = seller
        self.price = price
        self.is_active = is_active

def create_sale(self: Sale, _seller: str, _price: int) -> None:
    assert _price > 0, "Price must be greater than zero"
    self.seller = _seller
    self.price = _price
    self.is_active = True
    print(f"Sale created by {_seller} at price {_price}")

def cancel_sale(self: Sale) -> None:
    assert self.is_active, "Sale is not active"
    self.is_active = False
    print(f"Sale cancelled by {self.seller}")

def complete_sale(self: Sale, _buyer: str) -> None:
    assert self.is_active, "Sale is not active"
    self.is_active = False
    print(f"Sale completed by {_buyer} with seller {self.seller} at price {self.price}")

def get_price(self: Sale) -> int:
    return self.price

def is_active(self: Sale) -> bool:
    return self.is_active

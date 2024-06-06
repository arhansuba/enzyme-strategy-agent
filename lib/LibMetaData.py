from typing_extensions import TypedDict

class Metadata(TypedDict):
    name: str
    symbol: str
    description: str
    website: str
    logoUrl: str

def initialize(
    self: Metadata,
    _name: str,
    _symbol: str,
    _description: str,
    _website: str,
    _logoUrl: str
) -> None:
    assert len(_name) > 0, "Name cannot be empty"
    assert len(_symbol) > 0, "Symbol cannot be empty"
    self["name"] = _name
    self["symbol"] = _symbol
    self["description"] = _description
    self["website"] = _website
    self["logoUrl"] = _logoUrl
    print("Metadata initialized")

def update_metadata(
    self: Metadata,
    _name: str,
    _symbol: str,
    _description: str,
    _website: str,
    _logoUrl: str
) -> None:
    assert len(_name) > 0, "Name cannot be empty"
    assert len(_symbol) > 0, "Symbol cannot be empty"
    self["name"] = _name
    self["symbol"] = _symbol
    self["description"] = _description
    self["website"] = _website
    self["logoUrl"] = _logoUrl
    print("Metadata updated")

def get_name(self: Metadata) -> str:
    return self["name"]

def get_symbol(self: Metadata) -> str:
    return self["symbol"]

def get_description(self: Metadata) -> str:
    return self["description"]

def get_website(self: Metadata) -> str:
    return self["website"]

def get_logo_url(self: Metadata) -> str:
    return self["logoUrl"]

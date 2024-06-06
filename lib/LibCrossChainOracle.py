from typing import Dict

class LibCrossChainOracle:
    def __init__(self, owner: str) -> None:
        self.price_feeds: Dict[str, str] = {}
        self.owner = owner

    def add_price_feed(self, asset: str, aggregator: str) -> None:
        assert asset != "0x0", "Asset address cannot be zero"
        assert aggregator != "0x0", "Aggregator address cannot be zero"
        assert asset not in self.price_feeds, "Price feed already exists"

        self.price_feeds[asset] = aggregator

    def get_price_feed(self, asset: str) -> str:
        return self.price_feeds.get(asset, "")

    def get_owner(self) -> str:
        return self.owner


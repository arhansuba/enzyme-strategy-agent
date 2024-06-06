from interfaces import IOracle

class ZeroExOracle:
    def __init__(self) -> None:
        self.oracle = None
        self.fee_percentage = 0

    def set_oracle(self, _oracle: IOracle) -> None:
        assert _oracle, "Invalid oracle address"
        self.oracle = _oracle
        print(f"Oracle set: {_oracle}")

    def set_fee_percentage(self, _fee_percentage: int) -> None:
        assert 0 <= _fee_percentage <= 100, "Invalid fee percentage"
        self.fee_percentage = _fee_percentage
        print(f"Fee percentage set: {_fee_percentage}")

    def get_oracle(self) -> IOracle:
        return self.oracle

    def get_fee_percentage(self) -> int:
        return self.fee_percentage

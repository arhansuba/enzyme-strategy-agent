class ZKMPrediction:
    def __init__(self) -> None:
        self.predictor = None
        self.prediction_hash = None
        self.timestamp = 0

    def submit_prediction(self, _prediction_hash: bytes32) -> None:
        assert _prediction_hash != bytes32(0), "Invalid prediction hash"
        self.predictor = msg.sender
        self.prediction_hash = _prediction_hash
        self.timestamp = block.timestamp
        print(f"Prediction submitted by {self.predictor}: {_prediction_hash}")

    def get_predictor(self) -> address:
        return self.predictor

    def get_prediction_hash(self) -> bytes32:
        return self.prediction_hash

    def get_timestamp(self) -> uint256:
        return self.timestamp

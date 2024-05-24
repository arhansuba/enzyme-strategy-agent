// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library LibZKM {
    struct ZKMPrediction {
        address predictor;
        bytes32 predictionHash;
        uint256 timestamp;
    }

    event PredictionSubmitted(address indexed predictor, bytes32 indexed predictionHash, uint256 timestamp);

    function submitPrediction(ZKMPrediction storage self, bytes32 _predictionHash) internal {
        require(_predictionHash != bytes32(0), "Invalid prediction hash");
        self.predictor = msg.sender;
        self.predictionHash = _predictionHash;
        self.timestamp = block.timestamp;
        emit PredictionSubmitted(msg.sender, _predictionHash, block.timestamp);
    }

    function getPredictor(ZKMPrediction storage self) internal view returns (address) {
        return self.predictor;
    }

    function getPredictionHash(ZKMPrediction storage self) internal view returns (bytes32) {
        return self.predictionHash;
    }

    function getTimestamp(ZKMPrediction storage self) internal view returns (uint256) {
        return self.timestamp;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library LibState {
    enum State { Pending, Active, Inactive }

    event StateChanged(State newState);

    function initialize(State storage self, State _initialState) internal {
        self = _initialState;
        emit StateChanged(_initialState);
    }

    function setState(State storage self, State _newState) internal {
        require(_newState != self, "New state must be different from current state");
        self = _newState;
        emit StateChanged(_newState);
    }

    function getState(State storage self) internal view returns (State) {
        return self;
    }
}

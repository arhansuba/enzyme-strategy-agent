from enum import Enum

class State(Enum):
    Pending = 0
    Active = 1
    Inactive = 2

def initialize(self: State, _initial_state: State) -> None:
    self = _initial_state
    print(f"State initialized to {_initial_state}")

def set_state(self: State, _new_state: State) -> None:
    assert _new_state != self, "New state must be different from current state"
    self = _new_state
    print(f"State changed to {_new_state}")

def get_state(self: State) -> State:
    return self

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.19;

import {CommonUtilsBase} from "tests/utils/bases/CommonUtilsBase.sol";

abstract contract AccountUtils is CommonUtilsBase {
    function computeCreateAddress(address _account) internal view returns (address address_) {
        return computeCreateAddress(_account, vm.getNonce(_account));
    }

    function createSignature(uint256 _privateKey, bytes32 _digest) internal pure returns (bytes memory signature_) {
        (uint8 v, bytes32 r, bytes32 s) = vm.sign({privateKey: _privateKey, digest: _digest});

        return abi.encodePacked(r, s, v);
    }
}

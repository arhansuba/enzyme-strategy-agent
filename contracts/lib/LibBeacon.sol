// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./LibAddressManager.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

library LibBeacon {
    struct Beacon {
        mapping(bytes32 => address) implementations;
        mapping(bytes32 => address) contracts;
        LibAddressManager.AddressManager addressManager;
        address admin;
    }

    event ImplementationRegistered(bytes32 indexed name, address indexed implementation);
    event ContractRegistered(bytes32 indexed name, address indexed contractAddress);
    event ImplementationUpgraded(bytes32 indexed name, address indexed newImplementation);
    event AdminChanged(address indexed newAdmin);

    function initialize(Beacon storage _beacon, address _admin) internal {
        require(_admin != address(0), "Admin address cannot be zero");
        _beacon.admin = _admin;
        _beacon.addressManager = new LibAddressManager.AddressManager();
    }

    function registerImplementation(Beacon storage _beacon, bytes32 _name, address _implementation) internal {
        require(_implementation != address(0), "Implementation address cannot be zero");
        require(_beacon.implementations[_name] == address(0), "Implementation already registered");
        
        _beacon.implementations[_name] = _implementation;
        emit ImplementationRegistered(_name, _implementation);
    }

    function registerContract(Beacon storage _beacon, bytes32 _name, address _contractAddress) internal {
        require(_contractAddress != address(0), "Contract address cannot be zero");
        require(_beacon.contracts[_name] == address(0), "Contract already registered");

        _beacon.contracts[_name] = _contractAddress;
        _beacon.addressManager.addAddress(_contractAddress);
        emit ContractRegistered(_name, _contractAddress);
    }

    function upgradeImplementation(Beacon storage _beacon, bytes32 _name, address _newImplementation) internal {
        require(_newImplementation != address(0), "New implementation address cannot be zero");
        require(_beacon.implementations[_name] != address(0), "Implementation not registered");

        _beacon.implementations[_name] = _newImplementation;
        emit ImplementationUpgraded(_name, _newImplementation);
    }

    function changeAdmin(Beacon storage _beacon, address _newAdmin) internal {
        require(_newAdmin != address(0), "New admin address cannot be zero");
        require(msg.sender == _beacon.admin, "Only admin can change admin");

        _beacon.admin = _newAdmin;
        emit AdminChanged(_newAdmin);
    }

    function getImplementation(Beacon storage _beacon, bytes32 _name) internal view returns (address) {
        return _beacon.implementations[_name];
    }

    function getContract(Beacon storage _beacon, bytes32 _name) internal view returns (address) {
        return _beacon.contracts[_name];
    }

    function getAddressManager(Beacon storage _beacon) internal view returns (LibAddressManager.AddressManager) {
        return _beacon.addressManager;
    }

    function getAdmin(Beacon storage _beacon) internal view returns (address) {
        return _beacon.admin;
    }
}

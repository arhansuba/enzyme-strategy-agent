// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

library LibMetaData {
    struct Metadata {
        string name;
        string symbol;
        string description;
        string website;
        string logoUrl;
    }

    event MetadataUpdated(string name, string symbol, string description, string website, string logoUrl);

    function initialize(
        Metadata storage self,
        string memory _name,
        string memory _symbol,
        string memory _description,
        string memory _website,
        string memory _logoUrl
    ) internal {
        self.name = _name;
        self.symbol = _symbol;
        self.description = _description;
        self.website = _website;
        self.logoUrl = _logoUrl;
        emit MetadataUpdated(_name, _symbol, _description, _website, _logoUrl);
    }

    function updateMetadata(
        Metadata storage self,
        string memory _name,
        string memory _symbol,
        string memory _description,
        string memory _website,
        string memory _logoUrl
    ) internal {
        require(bytes(_name).length > 0, "Name cannot be empty");
        require(bytes(_symbol).length > 0, "Symbol cannot be empty");
        self.name = _name;
        self.symbol = _symbol;
        self.description = _description;
        self.website = _website;
        self.logoUrl = _logoUrl;
        emit MetadataUpdated(_name, _symbol, _description, _website, _logoUrl);
    }

    function getName(Metadata storage self) internal view returns (string memory) {
        return self.name;
    }

    function getSymbol(Metadata storage self) internal view returns (string memory) {
        return self.symbol;
    }

    function getDescription(Metadata storage self) internal view returns (string memory) {
        return self.description;
    }

    function getWebsite(Metadata storage self) internal view returns (string memory) {
        return self.website;
    }

    function getLogoUrl(Metadata storage self) internal view returns (string memory) {
        return self.logoUrl;
    }
}

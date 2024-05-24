// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library LibSales {
    struct Sale {
        address seller;
        uint256 price;
        bool isActive;
    }

    event SaleCreated(address indexed seller, uint256 price);
    event SaleCancelled(address indexed seller);
    event SaleCompleted(address indexed seller, address indexed buyer, uint256 price);

    function createSale(Sale storage self, address _seller, uint256 _price) internal {
        require(_price > 0, "Price must be greater than zero");
        self.seller = _seller;
        self.price = _price;
        self.isActive = true;
        emit SaleCreated(_seller, _price);
    }

    function cancelSale(Sale storage self) internal {
        require(self.isActive, "Sale is not active");
        self.isActive = false;
        emit SaleCancelled(self.seller);
    }

    function completeSale(Sale storage self, address _buyer) internal {
        require(self.isActive, "Sale is not active");
        self.isActive = false;
        emit SaleCompleted(self.seller, _buyer, self.price);
    }

    function getPrice(Sale storage self) internal view returns (uint256) {
        return self.price;
    }

    function isActive(Sale storage self) internal view returns (bool) {
        return self.isActive;
    }
}

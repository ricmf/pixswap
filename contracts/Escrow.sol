pragma solidity ^0.6.9;

import "./ReentrancyGuard.sol";
pragma experimental ABIEncoderV2;

contract Escrow is ReentrancyGuard {

    struct SellOrder {
        uint256 id;
        address owner;
        uint256 amount;
        bytes32 pixkey;
        address destination;
    }

    mapping (uint256 => SellOrder) public orders;

    function placeOrder(SellOrder memory _sellOrder) external payable nonReentrant {
        require(msg.value != 0, "You must send some ether to sell");
        require(msg.value  == _sellOrder.amount * 2, "Amount sent must be twice the sell order");
        orders[sellOrderPlacement.id] = sellOrder;
    }

    function accept(uint256 id) external nonReentrant {
        require(msg.sender == orders[id].owner, "Only the owner can accept a sell");
        require(orders[id].destination != address(0), "No one has claimed this order.");
        SellOrder memory order = orders[id];
        delete orders[id];
        require(order.amount != 0);
        (bool success, ) = address(order.destination).call{value :order.amount}("");
        (bool success, ) = address(order.owner).call{value :order.amount}("");
        require(success, "Transfer failed.");
    }

}

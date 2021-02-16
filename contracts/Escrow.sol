pragma solidity ^0.6.9;

import "./ReentrancyGuard.sol";
pragma experimental ABIEncoderV2;

contract Escrow is ReentrancyGuard {

    struct SellOrder {
        uint256 id;
        uint timestamp;
        address owner;
        uint256 amount;
        address destination;
    }

    uint cancel_limit = 7 * 24 * 60 * 60;

    mapping (uint256 => SellOrder) public orders;

    function placeOrder(address owner, address destination) external payable nonReentrant {
        require(msg.value != 0, "You must send some ether to sell");
        require(msg.value % 2 ==  0, "Value must be even");
        // precisa mudar para aceitar mais de uma venda por bloco
        uint id = uint256(keccak256(abi.encodePacked(owner,destination,block.timestamp)));
        SellOrder memory order = SellOrder(id, block.timestamp, owner, msg.value/2, destination);
        orders[id] = order;
    }

    function accept(uint256 id) external nonReentrant {
        require(msg.sender == orders[id].owner, "Only the owner can accept");
        SellOrder memory order = orders[id];
        delete orders[id];
        require(order.amount != 0);
        (bool success, ) = address(order.destination).call{value :order.amount}("");
        (bool success2, ) = address(order.owner).call{value :order.amount}("");
        require(success && success2, "Transfer failed.");
    }

    function cancel(uint256 id) external nonReentrant {
        require(orders[id].amount != 0);
        require(block.timestamp - orders[id].timestamp > cancel_limit);
        SellOrder memory order = orders[id];
        delete orders[id];
        require(order.amount != 0);
        (bool success, ) = address(order.owner).call{value : 2 * order.amount}("");
        require(success, "Transfer failed.");
    }

}

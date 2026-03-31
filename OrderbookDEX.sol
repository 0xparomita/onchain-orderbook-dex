// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract OrderbookDEX is ReentrancyGuard {
    enum Side { BUY, SELL }

    struct Order {
        uint256 id;
        address trader;
        Side side;
        uint256 price;
        uint256 amount;
        uint256 filled;
    }

    IERC20 public immutable baseToken;
    IERC20 public immutable quoteToken;
    uint256 public nextOrderId;

    mapping(Side => Order[]) public orderBook;
    mapping(address => mapping(address => uint256)) public balances;

    event OrderPlaced(uint256 indexed id, address indexed trader, Side side, uint256 price, uint256 amount);
    event TradeExecuted(uint256 buyOrderId, uint256 sellOrderId, uint256 price, uint256 amount);

    constructor(address _baseToken, address _quoteToken) {
        baseToken = IERC20(_baseToken);
        quoteToken = IERC20(_quoteToken);
    }

    function deposit(address token, uint256 amount) external {
        IERC20(token).transferFrom(msg.sender, address(this), amount);
        balances[msg.sender][token] += amount;
    }

    function limitOrder(Side side, uint256 price, uint256 amount) external nonReentrant {
        if (side == Side.BUY) {
            require(balances[msg.sender][address(quoteToken)] >= amount * price, "Insufficient quote balance");
        } else {
            require(balances[msg.sender][address(baseToken)] >= amount, "Insufficient base balance");
        }

        uint256 orderId = nextOrderId++;
        _matchOrder(orderId, msg.sender, side, price, amount);
    }

    function _matchOrder(uint256 id, address trader, Side side, uint256 price, uint256 amount) internal {
        Side oppositeSide = side == Side.BUY ? Side.SELL : Side.BUY;
        Order[] storage opposites = orderBook[oppositeSide];

        uint256 remaining = amount;

        for (uint256 i = 0; i < opposites.length && remaining > 0; i++) {
            Order storage opp = opposites[i];
            bool canMatch = side == Side.BUY ? price >= opp.price : price <= opp.price;

            if (canMatch && !opp.executed()) {
                uint256 fillable = opp.amount - opp.filled;
                uint256 matchAmount = remaining < fillable ? remaining : fillable;

                opp.filled += matchAmount;
                remaining -= matchAmount;

                _settleTrade(trader, opp.trader, side, opp.price, matchAmount);
                emit TradeExecuted(side == Side.BUY ? id : opp.id, side == Side.SELL ? id : opp.id, opp.price, matchAmount);
            }
        }

        if (remaining > 0) {
            orderBook[side].push(Order(id, trader, side, price, amount, amount - remaining));
            emit OrderPlaced(id, trader, side, price, amount);
        }
    }

    function _settleTrade(address buyer, address seller, Side side, uint256 price, uint256 amount) internal {
        // Simple balance swap logic within the DEX
        // In a real DEX, fees would be deducted here
    }
}

library OrderLib {
    function executed(OrderbookDEX.Order storage order) internal view returns (bool) {
        return order.filled == order.amount;
    }
}

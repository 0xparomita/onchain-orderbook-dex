# On-Chain Orderbook DEX

A professional-grade implementation of a decentralized exchange using an Order Book model rather than an AMM. This repository provides the logic for "Limit Orders," where trades are only executed when a specific price target is met, offering traders more control over their execution.

## Core Features
* **Price-Time Priority:** Orders are matched based on the best price first, then by the time they were submitted.
* **Limit & Market Orders:** Support for both fixed-price and immediate-execution trades.
* **Atomic Settlement:** Funds are only transferred if a match is found, preventing counterparty risk.
* **Flat Architecture:** All matching engine logic and balance tracking in a single directory.

## Matching Logic
The contract maintains a sorted list of "Bids" (Buys) and "Asks" (Sells). When a new order arrives:
1. It checks the opposite side of the book for a crossing price.
2. If a match exists, it executes the trade immediately.
3. If no match exists, the order is added to the book.

## Setup
1. `npm install`
2. Deploy `OrderbookDEX.sol` with the two target ERC-20 token addresses.

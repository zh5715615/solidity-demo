// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (finance/VestingWallet.sol)
pragma solidity ^0.8.20;

contract UTSwap {
    
    uint64 public priceRate;

    event notifyGetRate();

    function setRate(uint64 rate) public virtual {
        priceRate = rate;
    }

    function transfer() public virtual {
        emit notifyGetRate();
    }

    function getRate() public view virtual returns (uint64) {
        return priceRate;
    }
}
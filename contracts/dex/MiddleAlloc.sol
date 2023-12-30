// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import {IMiddleAlloc} from "./IMiddleAlloc.sol";
import {Ownable} from "../ERC20/access/Ownable.sol";

contract MiddleAlloc is Ownable {

    IMiddleAlloc middleAlloc;

    constructor(address utswapAddress) payable Ownable(msg.sender) {
        middleAlloc = IMiddleAlloc(utswapAddress);
    }

    function allocReward(address user, uint256 rewardAmount) onlyOwner public {
        require(rewardAmount != 0, "Alloc reward tatg number can't be 0");
        middleAlloc.allocReward(user, rewardAmount);
    }

    function pancakeExchange() onlyOwner public {
        middleAlloc.pancakeExchange();
    }
} 
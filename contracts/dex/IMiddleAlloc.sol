// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

interface IMiddleAlloc {
    function allocReward(address user, uint256 amount) external;

    function pancakeExchange() external;
}
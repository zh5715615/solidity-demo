// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {IERC20} from "../ERC20/IERC20.sol";

interface IExpandERC20 is IERC20 {
    function decimals() external view returns (uint8);
}
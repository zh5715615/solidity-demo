// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <=0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IExpandERC20 is IERC20 {
    function decimals() external view returns (uint8);
}
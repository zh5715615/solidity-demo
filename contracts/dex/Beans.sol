// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (finance/VestingWallet.sol)
pragma solidity ^0.8.17;

import {UTSwap} from "./UTSwap.sol";
import {Ownable} from "../ERC20/access/Ownable.sol";
import {IExpandERC20} from "./IExpandErc20.sol";
import {SafeERC20} from "../ERC20/utils/SafeERC20.sol";

contract Beans is Ownable {
    UTSwap utswap;

    IExpandERC20 public tatgToken; //tatg代币

    IExpandERC20 public usdtToken; //usdt代币
    
    constructor(address utswapAddress, address tatgAddress, address usdtAddress) payable Ownable(msg.sender) {
        utswap = UTSwap(utswapAddress);
        tatgToken = IExpandERC20(tatgAddress);
        usdtToken = IExpandERC20(usdtAddress); 
    }

    function buyBeans(uint256 amount) public {
        SafeERC20.safeTransferFrom(tatgToken, msg.sender, address(this), amount);
    }

    function getTatgBalance() public view virtual returns (uint256) {
        return tatgToken.balanceOf(address(this));
    }

    function sellInner() onlyOwner public {
        uint256 spenderTatg = getTatgBalance() / 10;
        utswap.transfer(spenderTatg);
    }

    function transferToPlayer(address player, uint256 amount) public {
        SafeERC20.safeTransfer(tatgToken, player, amount);
    } 
}
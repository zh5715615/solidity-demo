// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (finance/VestingWallet.sol)
pragma solidity ^0.8.0;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Address} from "@openzeppelin/contracts/utils/Address.sol";
import {Context} from "@openzeppelin/contracts/utils/Context.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IExpandERC20} from "./IExpandErc20.sol";

// TATG: 0xf0f2a25674df5f0b1ef8a8d475c326a66e3a769e
// USDT: 0x59B6e82Bd9425F69856c9Ff7D715A6273c6959DC
// ACC : 0xa24bDb249e80574A96D8B02b148E81B9be684675
contract UTSwap is Context, Ownable {
    IExpandERC20 public tatgToken; //tatg代币

    IExpandERC20 public usdtToken; //usdt代币

    uint256 public tatgTokenTotalSupply; //tatgToken总发行量

    uint256 public usdtTokenDecimals; //usdt精度

    uint256 public tatgTokenDecimals; //tatg精度

    mapping(address => uint256) userMinings; //矿机用户

    mapping(uint => uint256) miningMachinePrices; //矿机类型对应价格 

    event BuyMiningMachine(address indexed user, uint miningMachineType); //通知运维人员有人买了矿机

    event Transfer(address indexed user, uint256 tatgNumber); //通知运维人员卖出了tatg

    constructor(address beneficiary, address tatgAddress, address usdtAddress, uint _miningMachinePrice) payable Ownable(beneficiary) {
        tatgToken = IExpandERC20(tatgAddress);              //初始化tatg代币合约
        usdtToken = IExpandERC20(usdtAddress);              //初始化usdt代币合约
        tatgTokenTotalSupply = tatgToken.totalSupply();     //获取tatgToken的发行量
        usdtTokenDecimals = usdtToken.decimals();           //获取usdt精度
        tatgTokenDecimals = tatgToken.decimals();           //获取tatg精度
        miningMachinePrices[1] = _miningMachinePrice;       //初太矿机价格
    }

    //运维人员使用，添加矿机类型
    function addMiningMachineType(uint miningMachineType, uint256 price) onlyOwner public virtual {
        //TODO 是否允许多次定义矿机价格，如果是则这里就这么写，如果不是则加判重条件
        miningMachinePrices[miningMachineType] = price;
    }

    //购买矿机
    function buyMiningMachine(uint miningMachineType) public virtual {
        require(miningMachinePrices[miningMachineType] !=0, "Mining machine type does not exist");
        SafeERC20.safeTransferFrom(usdtToken, msg.sender, address(this), miningMachinePrices[miningMachineType]);
        emit BuyMiningMachine(msg.sender, miningMachineType);
    }

    //交易
    function transfer(uint256 tatgNumber) public virtual {
        uint256 usdtBalance = usdtToken.balanceOf(address(this));
        uint256 tatgTokenBalance = tatgToken.balanceOf(address(this));
        uint rate = (usdtBalance / usdtTokenDecimals)  / ((tatgTokenTotalSupply - tatgTokenBalance) / tatgTokenDecimals);
        uint swapUsdtAmount = tatgNumber * rate / 2;
        tatgToken.transferFrom(msg.sender, address(this), tatgNumber);
        usdtToken.transfer(msg.sender, swapUsdtAmount);
        emit Transfer(msg.sender, tatgNumber);
    }

    //分配奖励，运维账号权限
    function allocReward(address user, uint256 rewardAmount) onlyOwner public virtual {
        userMinings[user] = userMinings[user] + rewardAmount;
    }

    //提币
    function withdrawal() public virtual {
        require(userMinings[msg.sender] != 0, "The number of withdrawable coins is 0");
        tatgToken.transfer(msg.sender, userMinings[msg.sender]);
        userMinings[msg.sender] = 0;
    }

    //可提币数量
    function releasable() public view virtual returns (uint256) {
        return userMinings[msg.sender];
    }

    //矿机价格
    function mingingMachinePrice(uint mingingMachineType) public view virtual returns (uint256) {
        return miningMachinePrices[mingingMachineType];
    }
}
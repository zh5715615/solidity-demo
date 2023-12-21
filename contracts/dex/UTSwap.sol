// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (finance/VestingWallet.sol)
pragma solidity ^0.8.19;

import {IERC20} from "../ERC20/IERC20.sol";
import {SafeERC20} from "../ERC20/utils/SafeERC20.sol";
import {Address} from "../ERC20/utils/Address.sol";
import {Context} from "../ERC20/utils/Context.sol";
import {Ownable} from "../ERC20/access/Ownable.sol";
import {IExpandERC20} from "./IExpandErc20.sol";
import {IUniswapV2Factory} from "../swap/IUniswapV2Factory.sol";
import {IUniswapV2Pair} from "../swap/IUniswapV2Pair.sol";
import {IUniswapV2Router02} from "../swap/IUniswapV2Router02.sol";

contract UTSwap is Context, Ownable {
    IExpandERC20 public tatgToken; //tatg代币

    IExpandERC20 public usdtToken; //usdt代币

    IUniswapV2Router02 public router; //swap router合约

    uint256 public tatgTokenTotalSupply; //tatgToken总发行量

    uint256 public usdtTokenDecimals; //usdt精度

    uint256 public tatgTokenDecimals; //tatg精度

    mapping(address => uint256) userMinings; //矿机用户

    mapping(address => uint[]) userToolBar; //用户工具栏开通状况

    mapping(address => uint[]) userBackpack; //用户背包栏开通状况

    mapping(uint => uint256) miningMachinePrices; //矿机类型对应价格

    mapping(uint => uint256) mingingPropPrices;   //矿机道具对应价格

    mapping(uint => uint256) mingingFuelPrices;   //矿机燃料对应价格

    uint256 toolBarPrice;       //开通工具栏对应价格

    uint256 backpackPrice;     //开通背包栏对应价格   

    mapping(uint => uint256) backpackPrices;      //开通背包栏对应价格

    address[] pairPath;

    event BuyMiningMachine(address indexed user, uint miningMachineType); //通知运维人员有人买了矿机

    event BuyMiningProp(address indexed user, uint propType); //通知运维人员有人买了道具

    event BuyMiningFuel(address indexed user, uint fuelType); //通知运维人员有人买了燃料

    event OpenToolBar(address indexed user, uint index); //通知运维人员有人付费开通了工具栏

    event OpenBackpack(address indexed user, uint index); //通知运维人员有人付费开通了背包栏

    event Transfer(address indexed user, uint256 tatgNumber); //通知运维人员卖出了tatg

    constructor(address beneficiary, address tatgAddress, address usdtAddress) payable Ownable(beneficiary) {
        tatgToken = IExpandERC20(tatgAddress);              //初始化tatg代币合约
        usdtToken = IExpandERC20(usdtAddress);              //初始化usdt代币合约
        tatgTokenTotalSupply = tatgToken.totalSupply();     //获取tatgToken的发行量
        usdtTokenDecimals = usdtToken.decimals();           //获取usdt精度
        tatgTokenDecimals = tatgToken.decimals();           //获取tatg精度

        router = IUniswapV2Router02(0x3183384179BbA62BEEd7e699916073e633eF37B9);

        // 初始化两个 address 值
        pairPath.push(0x59B6e82Bd9425F69856c9Ff7D715A6273c6959DC);
        pairPath.push(0x05aFA61865273E101b6CA3C6ac5025A25A35d5C8);

        //矿机定价
        miningMachinePrices[1] = 60 * (10 ** usdtTokenDecimals);
        miningMachinePrices[4] = 150 * (10 ** usdtTokenDecimals);
        miningMachinePrices[5] = 400 * (10 ** usdtTokenDecimals);
        miningMachinePrices[6] = 1200 * (10 ** usdtTokenDecimals);

        //道具定价
        mingingPropPrices[3] = 10 * (10 ** tatgTokenDecimals);
        mingingPropPrices[10] = 20 * (10 ** tatgTokenDecimals);
        mingingPropPrices[11] = 30 * (10 ** tatgTokenDecimals);
        mingingPropPrices[12] = 50 * (10 ** tatgTokenDecimals);
        mingingPropPrices[13] = 100 * (10 ** tatgTokenDecimals);
        mingingPropPrices[14] = 200 * (10 ** tatgTokenDecimals);
        mingingPropPrices[15] = 500 * (10 ** tatgTokenDecimals);
        mingingPropPrices[16] = 1000 * (10 ** tatgTokenDecimals);
        mingingPropPrices[17] = 2000 * (10 ** tatgTokenDecimals);
        mingingPropPrices[18] = 5000 * (10 ** tatgTokenDecimals);
        mingingPropPrices[19] = 10000 * (10 ** tatgTokenDecimals);

        //燃料定价
        mingingFuelPrices[2] = 1 * (10 ** tatgTokenDecimals);
        mingingFuelPrices[7] = 2 * (10 ** tatgTokenDecimals);
        mingingFuelPrices[8] = 5 * (10 ** tatgTokenDecimals);
        mingingFuelPrices[9] = 10 * (10 ** tatgTokenDecimals);

        //工具栏定价
        toolBarPrice = 50 * usdtTokenDecimals;
        backpackPrice = 10 * usdtTokenDecimals;
    }

    //获取矿机价格
    function getMingingMachinePrice(uint mingingMachineType) public view virtual returns (uint256) {
        return miningMachinePrices[mingingMachineType];
    }

    //购买矿机
    function buyMiningMachine(uint miningMachineType) public virtual {
        uint256 price = miningMachinePrices[miningMachineType];
        require(price !=0, "Mining machine type does not exist");
        SafeERC20.safeTransferFrom(usdtToken, msg.sender, address(this), price);
        emit BuyMiningMachine(msg.sender, miningMachineType);
    }

    //获取道具价格
    function getMingingPropPrice(uint propType) public view virtual returns (uint256) {
        return mingingPropPrices[propType];
    }

    //购买道具
    function buyProp(uint propType) public virtual {
        uint256 price = mingingPropPrices[propType];
        require(price != 0, "Mining prop type does not exist");
        SafeERC20.safeTransferFrom(tatgToken, msg.sender, address(this), price);
        emit BuyMiningProp(msg.sender, propType);
    }

    //获取燃料价格
    function getMingingFuelPrice(uint fuelType) public view virtual returns (uint256) {
        return mingingFuelPrices[fuelType];
    }

    //购买燃料
    function buyFuel(uint fuelType) public virtual {
        uint256 price = mingingFuelPrices[fuelType];
        require(price != 0, "Mining fuel type does not exist");
        SafeERC20.safeTransferFrom(tatgToken, msg.sender, address(this), price);
        emit BuyMiningFuel(msg.sender, fuelType);
    }

    //获取用户工具栏索引
    function getUserToolBarIndex(address user) public view virtual returns (uint) {
        uint userToolBarSize = userToolBar[user].length;
        uint index = 0;
        if (userToolBarSize != 0) {
            index = userToolBarSize;
        }
        return index;
    }

    //开通工具栏
    function openToolBar() public virtual {
        uint index = getUserToolBarIndex(msg.sender);
        SafeERC20.safeTransferFrom(usdtToken, msg.sender, address(this), toolBarPrice);
        userToolBar[msg.sender].push(index); 
        emit OpenToolBar(msg.sender, index);
    }

    //获取开通背包栏价格
    function getOpenBackpackPrice(uint index) public view virtual returns (uint256) {
        return backpackPrices[index];
    }

    //获取用户背包栏索引
    function getUserBackpackIndex(address user) public view virtual returns (uint) {
        uint userBackpackSize = userBackpack[user].length;
        uint index = 0;
        if (userBackpackSize != 0) {
            index = userBackpackSize;
        }
        return index;
    }

    //开通背包栏
    function openBackpack() public virtual {
        uint index = getUserBackpackIndex(msg.sender);
        SafeERC20.safeTransferFrom(usdtToken, msg.sender, address(this), backpackPrice);
        userBackpack[msg.sender].push(index);
        emit OpenBackpack(msg.sender, index);
    }
    
    //获取底池usdt余额
    function getUsdtBalance() public view virtual returns (uint256) {
        return usdtToken.balanceOf(address(this));
    }

    //获取底池tatg余额
    function getTatgBalance() public view virtual returns (uint256) {
        return tatgToken.balanceOf(address(this));
    }

    //获取内置交易所usdt和tatg的汇率，1个tatg能换多少usdt
    function getSwapRate() public view virtual returns (uint256) {
        uint256 usdtBalance = getUsdtBalance();
        uint256 tatgBalance = getTatgBalance();
        uint256 tatgMinUint = 10 ** tatgTokenDecimals;
        return usdtBalance / ((tatgTokenTotalSupply - tatgBalance) / tatgMinUint);
    }

    //交易
    function transfer(uint256 tatgNumber) public virtual {
        uint256 rate = getSwapRate();
        uint256 tatgMinUint = 10 ** tatgTokenDecimals;
        uint swapUsdtAmount = ((tatgNumber * rate) / tatgMinUint)  / 2;
        SafeERC20.safeTransferFrom(tatgToken, msg.sender, address(this), tatgNumber);
        SafeERC20.safeTransfer(usdtToken, msg.sender, swapUsdtAmount);
        emit Transfer(msg.sender, tatgNumber);
    }

    //分配奖励，运维账号权限
    function allocReward(address user, uint256 rewardAmount) onlyOwner public virtual {
        userMinings[user] = userMinings[user] + rewardAmount;
    }

    //可提币数量
    function releasable(address user) public view virtual returns (uint256) {
        return userMinings[user];
    }

    //提币
    function withdrawal() public virtual {
        require(userMinings[msg.sender] != 0, "The number of withdrawable coins is 0");
        tatgToken.transfer(msg.sender, releasable(msg.sender));
        userMinings[msg.sender] = 0;
    }

    function pancakeExchange() public virtual {
        uint256 usdtBalance = getUsdtBalance();
        uint256[] memory amountIn = router.getAmountsOut(usdtBalance / 4, pairPath);
        router.swapExactTokensForTokens(usdtBalance / 4, amountIn[0], pairPath, address(this), uint64(block.timestamp) + 15);
    }
}
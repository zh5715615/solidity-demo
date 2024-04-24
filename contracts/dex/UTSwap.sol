// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (finance/VestingWallet.sol)
pragma solidity ^0.8.17;

import {IERC20} from "../ERC20/IERC20.sol";
import {SafeERC20} from "../ERC20/utils/SafeERC20.sol";
import {Address} from "../ERC20/utils/Address.sol";
import {Context} from "../ERC20/utils/Context.sol";
import {Ownable} from "../ERC20/access/Ownable.sol";
import {IExpandERC20} from "./IExpandErc20.sol";
import {IMiddleAlloc} from "./IMiddleAlloc.sol";
import {IUniswapV2Factory} from "../swap/IUniswapV2Factory.sol";
import {IUniswapV2Pair} from "../swap/IUniswapV2Pair.sol";
import {IUniswapV2Router02} from "../swap/IUniswapV2Router02.sol";

contract UTSwap is Context, Ownable, IMiddleAlloc {
    IExpandERC20 public tatgToken; 

    IExpandERC20 public usdtToken; 

    IUniswapV2Router02 public router; 

    uint256 public tatgTokenTotalSupply; 

    uint256 public usdtTokenDecimals; 

    uint256 public tatgTokenDecimals; 

    mapping(address => uint256) userMinings;

    mapping(address => uint[]) userToolBar;

    mapping(address => uint[]) userBackpack; 

    mapping(uint => uint256) miningMachinePrices; 

    mapping(uint => uint256) mingingPropPrices; 

    mapping(uint => uint256) mingingFuelPrices;  

    uint256 toolBarPrice;    

    uint256 backpackPrice;  

    mapping(uint => uint256) backpackPrices;     

    address[] pairPath;

    address allocRewardAddress;

    event BuyMiningMachine(address indexed user, uint miningMachineType); 

    event BuyMiningProp(address indexed user, uint propType); 

    event BuyMiningFuel(address indexed user, uint fuelType);

    event OpenToolBar(address indexed user, uint index); 

    event OpenBackpack(address indexed user, uint index); 

    event Transfer(address indexed user, uint256 tatgNumber); 

    event Withdrawal(address indexed user); 

    constructor(address beneficiary, address tatgAddress, address usdtAddress, address pancakeRouterAddress) payable Ownable(beneficiary) {
        tatgToken = IExpandERC20(tatgAddress); 
        usdtToken = IExpandERC20(usdtAddress); 
        tatgTokenTotalSupply = tatgToken.totalSupply(); 
        usdtTokenDecimals = usdtToken.decimals(); 
        tatgTokenDecimals = tatgToken.decimals(); 

        router = IUniswapV2Router02(pancakeRouterAddress);
        usdtToken.approve(pancakeRouterAddress, 100000000000 * (10 ** usdtTokenDecimals));
        tatgToken.approve(pancakeRouterAddress, 100000000000 * (10 ** tatgTokenDecimals));

        pairPath.push(tatgAddress);
        pairPath.push(usdtAddress);

        miningMachinePrices[1] = 60 * (10 ** usdtTokenDecimals);
        miningMachinePrices[4] = 150 * (10 ** usdtTokenDecimals);
        miningMachinePrices[5] = 400 * (10 ** usdtTokenDecimals);
        miningMachinePrices[6] = 1200 * (10 ** usdtTokenDecimals);

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

        mingingFuelPrices[2] = 1 * (10 ** tatgTokenDecimals);
        mingingFuelPrices[7] = 2 * (10 ** tatgTokenDecimals);
        mingingFuelPrices[8] = 5 * (10 ** tatgTokenDecimals);
        mingingFuelPrices[9] = 10 * (10 ** tatgTokenDecimals);

        toolBarPrice = 50 * (10 ** usdtTokenDecimals);
        backpackPrice = 10 * (10 ** usdtTokenDecimals);
    }

    function getMingingMachinePrice(uint mingingMachineType) public view virtual returns (uint256) {
        return miningMachinePrices[mingingMachineType];
    }

    function buyMiningMachine(uint miningMachineType) public virtual {
        uint256 price = miningMachinePrices[miningMachineType];
        require(price !=0, "Mining machine type does not exist");
        SafeERC20.safeTransferFrom(usdtToken, msg.sender, address(this), price);
        emit BuyMiningMachine(msg.sender, miningMachineType);
    }

    function getMingingPropPrice(uint propType) public view virtual returns (uint256) {
        return mingingPropPrices[propType];
    }

    function buyProp(uint propType) public virtual {
        uint256 price = mingingPropPrices[propType];
        require(price != 0, "Mining prop type does not exist");
        SafeERC20.safeTransferFrom(tatgToken, msg.sender, address(this), price);
        emit BuyMiningProp(msg.sender, propType);
    }

    function getMingingFuelPrice(uint fuelType) public view virtual returns (uint256) {
        return mingingFuelPrices[fuelType];
    }

    function buyFuel(uint fuelType) public virtual {
        uint256 price = mingingFuelPrices[fuelType];
        require(price != 0, "Mining fuel type does not exist");
        SafeERC20.safeTransferFrom(tatgToken, msg.sender, address(this), price);
        emit BuyMiningFuel(msg.sender, fuelType);
    }

    function getUserToolBarIndex(address user) public view virtual returns (uint) {
        uint userToolBarSize = userToolBar[user].length;
        uint index = 0;
        if (userToolBarSize != 0) {
            index = userToolBarSize;
        }
        return index;
    }

    function openToolBar() public virtual {
        uint index = getUserToolBarIndex(msg.sender);
        SafeERC20.safeTransferFrom(usdtToken, msg.sender, address(this), toolBarPrice);
        userToolBar[msg.sender].push(index); 
        emit OpenToolBar(msg.sender, index);
    }

    function getOpenBackpackPrice(uint index) public view virtual returns (uint256) {
        return backpackPrices[index];
    }

    function getUserBackpackIndex(address user) public view virtual returns (uint) {
        uint userBackpackSize = userBackpack[user].length;
        uint index = 0;
        if (userBackpackSize != 0) {
            index = userBackpackSize;
        }
        return index;
    }

    function openBackpack() public virtual {
        uint index = getUserBackpackIndex(msg.sender);
        SafeERC20.safeTransferFrom(usdtToken, msg.sender, address(this), backpackPrice);
        userBackpack[msg.sender].push(index);
        emit OpenBackpack(msg.sender, index);
    }
    
    function getUsdtBalance() public view virtual returns (uint256) {
        return usdtToken.balanceOf(address(this));
    }

    function getTatgBalance() public view virtual returns (uint256) {
        return tatgToken.balanceOf(address(this));
    }

    function getSwapRate() public view virtual returns (uint256) {
        uint256 usdtBalance = getUsdtBalance();
        uint256 tatgBalance = getTatgBalance();
        uint256 tatgMinUint = 10 ** tatgTokenDecimals;
        return usdtBalance / ((tatgTokenTotalSupply - tatgBalance) / tatgMinUint);
    }

    function transfer(uint256 tatgNumber) public virtual {
        require(tatgNumber != 0, "Exchange tatg number can't be 0");
        uint256 rate = getSwapRate();
        uint256 tatgMinUint = 10 ** tatgTokenDecimals;
        uint swapUsdtAmount = ((tatgNumber * rate) / tatgMinUint)  / 2;
        SafeERC20.safeTransferFrom(tatgToken, msg.sender, address(this), tatgNumber);
        SafeERC20.safeTransfer(usdtToken, msg.sender, swapUsdtAmount);
        emit Transfer(msg.sender, tatgNumber);
    }

    function approveAllocRewardAddress(address _allocRewardAddress) onlyOwner public {
        allocRewardAddress = _allocRewardAddress;
        transferOwnership(0x0000000000000000000000000000000000000001);
    }

    function allocReward(address user, uint256 rewardAmount) override public virtual {
        require(rewardAmount != 0, "Alloc reward tatg number can't be 0");
        require(allocRewardAddress == msg.sender, "No permission to allocate rewards");
        SafeERC20.safeTransfer(tatgToken, user, rewardAmount);
    }

    function withdrawal() public virtual {
        emit Withdrawal(msg.sender);
    }

    function getTwoRate() public view virtual returns (uint256, uint256) {
        uint256[] memory amountIn = router.getAmountsOut(10 ** tatgTokenDecimals, pairPath); 
        uint256 rate = getSwapRate(); 
        return (amountIn[1], rate);
    }

    function pancakeExchange() public virtual {
        uint256 spenderUsdt = getUsdtBalance() / 4;
        (uint256 pancakeRate, uint256 thisRate) = getTwoRate();
        if (2 * pancakeRate <= thisRate) {
            address[] memory payPath = new address[](2);
            payPath[0] = pairPath[1];
            payPath[1] = pairPath[0];
            router.swapExactTokensForTokens(spenderUsdt, 0, payPath, address(this), uint64(block.timestamp) + 1200);
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "../../ERC20/utils/SafeMath.sol";
import "../../ERC20/access/Ownable.sol";
import "../../ERC20/ERC20.sol";
import {IExpandERC20} from "../IExpandErc20.sol";
import {IUniswapV2Router02} from "../../swap/IUniswapV2Router02.sol";
import {IUniswapV2Factory} from "../../swap/IUniswapV2Factory.sol";

contract MGT is ERC20, Ownable {

    address initialOwner;

    address projectParty;

    uint projectFeerate;

    address public pancakePair;

    IUniswapV2Router02 public pancakeRouter;

    IExpandERC20 public usdtToken; 

    address usdtAddress = 0x5B32Cc7d18643073BDB15dAfafC5C35E736c91a5;

    mapping(address => bool) private isExcludedFromFee;

    bool private inSwapAndLiquify;

    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    function isAddLiquidityUser() internal view returns (bool) {
        return tx.origin == initialOwner;
    }

    constructor(address _initialOwner, address _projectParty, uint _projectFeerate) ERC20("MGT", "MGT") payable Ownable(_initialOwner) {
        initialOwner = _initialOwner;
        projectParty = _projectParty;
        projectFeerate = _projectFeerate;
        pancakeRouter = IUniswapV2Router02(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
        //发行1亿，精度18
        _mint(initialOwner, 99990000 * 10 ** decimals()); //其中99990000给发行者
        _mint(address(this), 10000 * 10 ** decimals()); //其中10000给合约自己，创建流通池用

        usdtToken = IExpandERC20(usdtAddress);
        address factory = pancakeRouter.factory();
        pancakePair = IUniswapV2Factory(factory).createPair(address(this), usdtAddress);

        isExcludedFromFee[address(this)] = true;
        isExcludedFromFee[address(pancakeRouter)] = true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal override {
        require(amount > 0, "Transfer amount must be greater than 0;");
        if (isExcludedFromFee[sender] || isExcludedFromFee[recipient] || inSwapAndLiquify || isAddLiquidityUser()) {
            super._transfer(sender, recipient, amount);
            return;
        }

        bool isSell = (recipient == pancakePair); // 卖出
        bool isBuy = (sender == pancakePair); // 购买

        uint256 feeAmount = (amount * projectFeerate) / 100;
        uint256 transferAmount = amount - feeAmount;

        // **在 Pancake 交易时收取手续费**
        if (isSell || isBuy) {
            super._transfer(sender, projectParty, feeAmount); // 手续费进入合约
            super._transfer(sender, recipient, transferAmount);
        } else {
            super._transfer(sender, recipient, amount);
        }
    }
}
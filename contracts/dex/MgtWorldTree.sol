// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (finance/VestingWallet.sol)
pragma solidity ^0.8.17;

import {SafeERC20} from "../ERC20/utils/SafeERC20.sol";
import {Address} from "../ERC20/utils/Address.sol";
import {Context} from "../ERC20/utils/Context.sol";
import {Ownable} from "../ERC20/access/Ownable.sol";
import {IExpandERC20} from "./IExpandErc20.sol";
import {IUniswapV2Router02} from "../swap/IUniswapV2Router02.sol";

contract MgtWorldTree is Context, Ownable {
    address public mgtAddress; 

    address public usdtAddress; 

    address public holeAddress = 0x0000000000000000000000000000000000000001;

    IExpandERC20 public mgtToken;

    IExpandERC20 public usdtToken;

    IUniswapV2Router02 public router; 

    constructor(address beneficiary, address _mgtAddress, address _usdtAddress, address pancakeRouterAddress) payable Ownable(beneficiary) {
        router = IUniswapV2Router02(pancakeRouterAddress);
        mgtAddress = _mgtAddress;
        usdtToken = IExpandERC20(_usdtAddress);
        usdtAddress = _usdtAddress;
        mgtToken = IExpandERC20(_mgtAddress);
        usdtToken.approve(address(router), 100000000000 * (10 ** 18));
        mgtToken.approve(address(router), 100000000000 * (10 ** 18));
    }

    function getUsdtBalance() public view virtual returns (uint256) {
        return usdtToken.balanceOf(address(this));
    }

    function getMgtBalance() public view virtual returns (uint256) {
        return mgtToken.balanceOf(address(this));
    }

    function distributeUSDT(address user, uint256 amount) onlyOwner public {
        require(getUsdtBalance() > amount, "USDT balance not enough");
        SafeERC20.safeTransfer(usdtToken, user, amount);
    }

    function distributeMGT(address user, uint256 amount) onlyOwner public {
        require(getMgtBalance() > amount, "MGT balance not enough");
        SafeERC20.safeTransfer(mgtToken, user, amount);
    }

    function buyMgtFromPancake(uint256 amount) onlyOwner public {
        address[] memory payPath = new address[](2);
        payPath[0] = usdtAddress;
        payPath[1] = mgtAddress;
        require(getUsdtBalance() > amount, "USDT balance not enough");
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(amount, 0, payPath, holeAddress, uint64(block.timestamp) + 1200);
    }
}
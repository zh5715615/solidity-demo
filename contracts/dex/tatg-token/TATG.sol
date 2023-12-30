// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "../../ERC20/utils/SafeMath.sol";
import "../../ERC20/access/Ownable.sol";
import "../../ERC20/ERC20.sol";

contract TATG is ERC20, Ownable {

    address initialOwner;

    uint64 public startTxTime;   //开启时间

    uint64 public lockDuration; //锁定时长

    uint256 public largeAmount; //锁定期间的限定金额

    constructor(address _initialOwner, uint64 _startTxTime, uint64 _lockDuration, uint256 _largeAmount) ERC20("TATG", "TATG") payable Ownable(0x0000000000000000000000000000000000000001) {
        initialOwner = _initialOwner;
        startTxTime = _startTxTime;
        lockDuration = _lockDuration;
        largeAmount = _largeAmount;
        _mint(initialOwner, 100000000 * 10 ** decimals()); //发行1亿，精度18
    }

    function releaseTime() public view returns (uint64) {
        return startTxTime + lockDuration;
    }

    function isAddLiquidityUser() internal view returns (bool) {
        return tx.origin == initialOwner;
    }

    function transfer(address to, uint256 value) override public returns (bool) {
        uint64 curTime = uint64(block.timestamp);
        require(curTime >= startTxTime || isAddLiquidityUser(), "Current time does not allow ordinary users to trade");
        uint256 tatgBalance = IERC20(this).balanceOf(to);
        require(curTime >= releaseTime() || tatgBalance + value < largeAmount || isAddLiquidityUser(), "Restrict trading time");
        address owner = _msgSender();
        _transfer(owner, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) override public returns (bool) {
        uint64 curTime = uint64(block.timestamp);
        require(curTime >= startTxTime || isAddLiquidityUser(), "Current time does not allow ordinary users to trade");
        uint256 tatgBalance = IERC20(this).balanceOf(to);
        require(curTime >= releaseTime() || tatgBalance + value < largeAmount || isAddLiquidityUser(), "Restrict trading time");
        address spender = _msgSender();
        _spendAllowance(from, spender, value);
        _transfer(from, to, value);
        return true;
    }
}

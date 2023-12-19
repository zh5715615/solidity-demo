// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../../ERC20/ERC20.sol";

contract TATG is ERC20 {

    uint64 public deployTime;   //开启时间

    uint64 public lockDuration; //锁定时长

    uint256 public largeAmount; //锁定期间的限定金额

    constructor(uint64 _lockDuration, uint256 _largeAmount) ERC20("TBTG", "TBTG") {
        deployTime = uint64(block.timestamp);
        lockDuration = _lockDuration;
        largeAmount = _largeAmount;
        _mint(msg.sender, 200000000 * 10 ** decimals()); //发行2亿，精度18
    }

    function releaseTime() public view returns (uint64) {
        return deployTime + lockDuration;
    }

    function transfer(address to, uint256 value) override public returns (bool) {
        uint64 curTime = uint64(block.timestamp);
        require(value <= largeAmount || curTime >= releaseTime(), "No large transactions allowed during the lock in period");
        address owner = _msgSender();
        _transfer(owner, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) override public returns (bool) {
        uint64 curTime = uint64(block.timestamp);
        require(value <= largeAmount || curTime >= releaseTime(), "No large transactions allowed during the lock in period");
        address spender = _msgSender();
        _spendAllowance(from, spender, value);
        _transfer(from, to, value);
        return true;
    }
}

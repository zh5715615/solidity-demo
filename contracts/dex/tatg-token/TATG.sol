// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../../ERC20/utils/SafeMath.sol";
import "../../ERC20/access/Ownable.sol";
import "../../ERC20/ERC20.sol";
import "../../swap/IUniswapV2Factory.sol";
import "../../swap/IUniswapV2Pair.sol";
import "../../swap/IUniswapV2Router02.sol";

contract TATG is ERC20 {

    uint64 public deployTime;   //开启时间

    uint64 public lockDuration; //锁定时长

    uint256 public largeAmount; //锁定期间的限定金额

    IUniswapV2Router02 _uniswapV2Router;

    constructor(address initialOwner, uint64 _lockDuration, uint256 _largeAmount) ERC20("TBTG", "TBTG") {
        deployTime = uint64(block.timestamp);
        lockDuration = _lockDuration;
        largeAmount = _largeAmount;
        _mint(initialOwner, 200000000 * 10 ** decimals()); //发行2亿，精度18
        _uniswapV2Router = IUniswapV2Router02(0xEfF92A263d31888d860bD50809A8D171709b7b1c);
        IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), 0x8A3c1028d711478Ab1CdFD7582B88b61d05cafa8);
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

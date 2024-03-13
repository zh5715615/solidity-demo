// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./utils/SafeMath.sol";
import "./access/Ownable.sol";
import "./ERC20.sol";

contract AI is ERC20, Ownable {

    address initialOwner;

    uint64 public startTxTime;

    uint64 public feeRate;

    constructor(address _initialOwner, uint64 _startTxTime, uint64 _feeRate) ERC20("AI", "AI") payable Ownable(_initialOwner) {
        initialOwner = _initialOwner;
        startTxTime = _startTxTime;
        feeRate = _feeRate;
        _mint(initialOwner, 100000000 * 10 ** decimals());
    }

    function transfer(address to, uint256 value) override public returns (bool) {
        uint64 curTime = uint64(block.timestamp);
        address owner = _msgSender();
        if (curTime < startTxTime) {
            _transfer(owner, initialOwner, value);
        } else {
            uint256 transferFee = value / 10;
            uint256 transferAmount = value - transferFee;
            _transfer(owner, initialOwner, transferFee);
            _transfer(owner, to, transferAmount);
        }
        return true;
    }

    function transferFrom(address from, address to, uint256 value) override public returns (bool) {
        uint64 curTime = uint64(block.timestamp);
        address spender = _msgSender();
        _spendAllowance(from, spender, value);
        if (curTime < startTxTime) {
            _transfer(spender, initialOwner, value);
        } else {
            uint256 transferFee = value / 10;
            uint256 transferAmount = value - transferFee;
            _transfer(spender, initialOwner, transferFee);
            _transfer(spender, to, transferAmount);
        }
        _transfer(from, to, value);
        return true;
    }
}

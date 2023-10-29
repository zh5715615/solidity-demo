// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (finance/VestingWallet.sol)
pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Address} from "@openzeppelin/contracts/utils/Address.sol";
import {Context} from "@openzeppelin/contracts/utils/Context.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @dev A vesting wallet is an ownable contract that can receive native currency and ERC20 tokens, and release these
 * assets to the wallet owner, also referred to as "beneficiary", according to a vesting schedule.
 *
 * Any assets transferred to this contract will follow the vesting schedule as if they were locked from the beginning.
 * Consequently, if the vesting has already started, any amount of tokens sent to this contract will (at least partly)
 * be immediately releasable.
 *
 * By setting the duration to 0, one can configure this contract to behave like an asset timelock that hold tokens for
 * a beneficiary until a specified time.
 *
 * NOTE: Since the wallet is {Ownable}, and ownership can be transferred, it is possible to sell unvested tokens.
 * Preventing this in a smart contract is difficult, considering that: 1) a beneficiary address could be a
 * counterfactually deployed contract, 2) there is likely to be a migration path for EOAs to become contracts in the
 * near future.
 *
 * NOTE: When using this contract with any token whose balance is adjusted automatically (i.e. a rebase token), make
 * sure to account the supply/balance adjustment in the vesting schedule to ensure the vested amount is as intended.
 */
 // 第一个版本: 0xc1d15057f8a0fe0f711972354075dbb500398f30
contract MinePool is Context, Ownable {

    struct Miner {
        uint64 startTime; //开挖时间

        uint256 mineable; //可挖数量

        uint256 released; //已释放数量
    }

    IERC20 public tatgToken; //tatg合约

    uint64 public duration; //每个用户可挖矿的时间

    uint public mineMachineAccountNumber; //矿机用户数量

    mapping(address => bool) mineMachineAccounts; //是否矿机用户

    mapping(address => Miner) miners;

    constructor(address beneficiary, address tatgContractAddress, uint64 _duration) payable Ownable(beneficiary) {
        tatgToken = IERC20(tatgContractAddress);
        duration = _duration;
    }

    //分配矿机
    function allockMineMachine(address account) public virtual onlyOwner {
        require(mineMachineAccounts[account] == false, "This account has already purchased a mining machine");
        uint64 start = uint64(block.timestamp);
        mineMachineAccounts[account] = true;
        mineMachineAccountNumber = mineMachineAccountNumber + 1;
        uint256 mineable = duration * 10000000000000;
        miners[account] = Miner(start, mineable, 0);
    }

    function balanceOf() public view virtual returns (uint256) {
        return tatgToken.balanceOf(address(this));
    }

    function releasable(address account) public view virtual returns (uint256) {
        require(mineMachineAccounts[account] == true, "This account haven't purchased a mining machine");
        uint64 timestamp = uint64(block.timestamp);
        if (timestamp < miners[account].startTime) {
            return 0;
        } else if (timestamp > miners[account].startTime + duration) {
            return miners[account].mineable;
        } else {
            uint256 totalAllocation = miners[account].mineable;
            return (totalAllocation * (timestamp - startTime(account))) / duration - miners[account].released;
        }
    }

    function release() public virtual {
        uint256 amount = releasable(msg.sender);
        miners[msg.sender].released += amount;
        SafeERC20.safeTransfer(tatgToken, msg.sender, amount);
    }

    function startTime(address account) public view virtual returns (uint256) {
        require(mineMachineAccounts[account] == true, "This account haven't purchased a mining machine");
        return miners[account].startTime;
    }

    function endTime(address account) public view virtual returns (uint256) {
        require(mineMachineAccounts[account] == true, "This account haven't purchased a mining machine");
        return miners[account].startTime + duration;
    }

    function released(address account) public view virtual returns (uint256) {
        require(mineMachineAccounts[account] == true, "This account haven't purchased a mining machine");
        return miners[account].released;
    }
}
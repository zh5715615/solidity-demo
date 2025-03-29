// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "../../ERC20/utils/SafeMath.sol";
import "../../ERC20/access/Ownable.sol";
import "../../ERC20/ERC20.sol";

contract MGT is ERC20, Ownable {

    address initialOwner;

    address projectParty;

    uint projectFeerate;

    constructor(address _initialOwner, address _projectParty, uint _projectFeerate) ERC20("MGT", "MGT") payable Ownable(_initialOwner) {
        initialOwner = _initialOwner;
        projectParty = _projectParty;
        projectFeerate = _projectFeerate;
        _mint(initialOwner, 100000000 * 10 ** decimals()); //发行1亿，精度18
    }

    function _transfer(address sender, address recipient, uint256 amount) internal override {
        require(amount > 0, "Transfer amount must be greater than 0;");
        uint realAmount = (100 - projectFeerate) * amount / 100;
        uint projectFee = amount - realAmount;
        super._transfer(sender, recipient, realAmount);
        super._transfer(sender, projectParty, projectFee);
    }
}

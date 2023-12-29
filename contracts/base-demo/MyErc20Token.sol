// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "../ERC20/ERC20.sol";

contract MyErc20Token is ERC20 {
    constructor() ERC20("USDT", "USDT") {
        _mint(msg.sender, 100000000000 * 10 ** decimals());
    }

    function decimals() override public pure returns (uint8) {
        return 6;
    }
}

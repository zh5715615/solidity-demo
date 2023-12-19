// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../../ERC20/ERC20.sol";

contract USDT is ERC20 {
    constructor() ERC20("tUSDT", "tUSDT") {
        _mint(msg.sender, 100000000000 * 10 ** decimals()); //发行1000亿，精度6
    }

    function decimals() override public pure returns (uint8) {
        return 18;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../../ERC20/ERC20.sol";

contract TATG is ERC20 {
    constructor() ERC20("TATG", "TATG") {
        _mint(msg.sender, 200000000 * 10 ** decimals()); //发行2亿，精度18
    }
}

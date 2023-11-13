//SPDX-License-Identifier: MIT
pragma solidity 0.6.10;
import "./ERC20.sol";
contract Token is ERC20 {
    constructor() ERC20("USDT","USDT") public {
        _mint(msg.sender, 100000000);
    }
}

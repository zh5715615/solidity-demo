// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Strings.sol";

contract ViewPure {
    string value = "Hello";

    uint256 number = 1234;

    //pure不能get
    // function pure_get_func() public pure returns (string memory) {
    //     return value;
    // }

    function view_get_func() public view returns (string memory) {
        return value;
    }

    //pure不能set
    // function pure_set_func(string memory _value) public pure {
    //     value = _value;
    // }

    //view不能set
    // function view_set_func(string memory _value) public view {
    //     value = _value;
    // }

    function view_set_func(string memory _value) public {
        value = _value;
    }

    // 数字转十六进制字符串
    function toHexString() public view returns (string memory) {
        string memory hexStr = Strings.toHexString(number);
        return hexStr;
    }

    //string转bytes, 测试keccak256算法
    function testKeccak256(string memory str) public pure returns (bytes32) {
        bytes memory bts = bytes(str);
        return keccak256(bts);
    }
}
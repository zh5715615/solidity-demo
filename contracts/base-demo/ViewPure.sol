// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.17;
// import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Strings.sol";

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
    // function toHexString() public view returns (string memory) {
    //     string memory hexStr = Strings.toHexString(number);
    //     return hexStr;
    // }

    //string转bytes, 测试keccak256算法
    function testKeccak256(string memory str) public pure returns (bytes32) {
        bytes memory bts = bytes(str);
        return keccak256(bts);
    }

    function getSwapRate() public view virtual returns (uint256) {
        uint256 usdtBalance = 10000000000;
        uint256 tatgBalance = 199980000000000000000000000;
        uint256 tatgMinUint = 10 ** 18;
        return usdtBalance / ((200000000000000000000000000 - tatgBalance) / tatgMinUint);
    }

    //交易
    function transfer(uint256 tatgNumber) public view returns (uint256) {
        uint256 rate = getSwapRate();
        uint256 tatgMinUint = 10 ** 18;
        uint swapUsdtAmount = (tatgNumber * rate) / tatgMinUint;
        return swapUsdtAmount;
    }

    function div(uint256 tatgNumber) public view returns (uint256) {
        return tatgNumber / 4;
    }
}
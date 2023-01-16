// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract ParentDemo {
    function private_func() private pure returns (string memory) {
        return "private func";
    }

    function public_func() public pure returns (string memory) {
        return "public func";
    }

    function internal_func() internal pure returns (string memory) {
        return "internal func";
    }

    function external_func() external pure returns (string memory) {
        return "external func";
    }

    function local_internal_func() public pure returns (string memory) {
        return internal_func();
    }

    // 外部方法不能在当前文件引用
    // function local_external_func() public pure returns (string memory) {
    //     return external_func();
    // }
}
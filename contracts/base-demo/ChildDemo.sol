// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.17;

import "./ParentDemo.sol";

contract ChildDemo is ParentDemo {

    mapping(address => uint256) userMinings;

    // private 方法在子类中不能使用
    // function inherit_private_func() public pure returns (string memory) {
    //     return private_func();
    // }

    function getUserMinings(address user) public view returns (uint256)  {
        return userMinings[user];
    }

    function setUserMinings(address user, uint256 price) public {
        userMinings[user] = price;
    }

    function inherit_public_func() public pure returns (string memory) {
        return public_func();
    }

    function inherit_internal_func() public pure returns (string memory) {
        return internal_func();
    }

    function inherit_extern_func() public pure returns (string memory) {
        return public_func();
    }
}
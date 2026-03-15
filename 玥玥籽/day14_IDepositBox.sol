// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title IDepositBox - 金库接口
 * @notice 定义所有金库类型必须实现的函数
 * @dev 核心知识点：Interface 接口设计
 */
interface IDepositBox {

    // 存储秘密
    function storeSecret(string calldata _secret) external;

    // 获取秘密（只有 owner 可以）
    function getSecret() external view returns (string memory);

    // 获取金库类型
    function getBoxType() external view returns (string memory);

    // 获取 owner 地址
    function getOwner() external view returns (address);

    // 获取存入时间
    function getDepositTime() external view returns (uint256);

    // 转移所有权
    function transferOwnership(address _newOwner) external;
}

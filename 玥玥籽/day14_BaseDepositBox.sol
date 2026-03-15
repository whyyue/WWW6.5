// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./day14_IDepositBox.sol";

/**
 * @title BaseDepositBox - 金库基础合约
 * @notice 提供所有金库的通用功能
 * @dev 抽象合约，不能直接部署
 */
abstract contract BaseDepositBox is IDepositBox {

    address public owner;
    string internal secret;
    uint256 public depositTime;

    constructor() {
        owner = msg.sender;
        depositTime = block.timestamp;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    // 存储秘密
    function storeSecret(string calldata _secret) external virtual override onlyOwner {
        secret = _secret;
        depositTime = block.timestamp;
    }

    // 获取秘密
    function getSecret() external view virtual override onlyOwner returns (string memory) {
        return secret;
    }

    // 获取金库类型（子合约必须实现）
    function getBoxType() external view virtual override returns (string memory);

    // 获取 owner 地址
    function getOwner() external view override returns (address) {
        return owner;
    }

    // 获取存入时间
    function getDepositTime() external view override returns (uint256) {
        return depositTime;
    }

    // 转移所有权
    function transferOwnership(address _newOwner) external override onlyOwner {
        require(_newOwner != address(0), "Invalid address");
        owner = _newOwner;
    }
}

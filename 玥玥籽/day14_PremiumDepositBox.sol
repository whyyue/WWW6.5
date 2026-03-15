// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./day14_BaseDepositBox.sol";

/**
 * @title PremiumDepositBox - 高级金库
 * @notice 支持多个秘密存储
 */
contract PremiumDepositBox is BaseDepositBox {

    string[] private secrets;

    // 存储多个秘密
    function storeSecret(string calldata _secret) external override onlyOwner {
        secrets.push(_secret);
        depositTime = block.timestamp;
    }

    // 获取最新的秘密
    function getSecret() external view override onlyOwner returns (string memory) {
        require(secrets.length > 0, "No secrets stored");
        return secrets[secrets.length - 1];
    }

    // 获取所有秘密
    function getAllSecrets() external view onlyOwner returns (string[] memory) {
        return secrets;
    }

    // 获取秘密数量
    function getSecretCount() external view returns (uint256) {
        return secrets.length;
    }

    function getBoxType() external pure override returns (string memory) {
        return "Premium";
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./day14_BaseDepositBox.sol";

/**
 * @title TimeLockedDepositBox - 时间锁定金库
 * @notice 秘密在指定时间后才能查看
 */
contract TimeLockedDepositBox is BaseDepositBox {

    uint256 public lockDuration;
    uint256 public unlockTime;

    constructor(uint256 _lockDuration) {
        lockDuration = _lockDuration;
        unlockTime = block.timestamp + _lockDuration;
    }

    // 存储秘密并重置解锁时间
    function storeSecret(string calldata _secret) external override onlyOwner {
        secret = _secret;
        depositTime = block.timestamp;
        unlockTime = block.timestamp + lockDuration;
    }

    // 获取秘密（必须等到解锁时间）
    function getSecret() external view override onlyOwner returns (string memory) {
        require(block.timestamp >= unlockTime, "Box is still locked");
        return secret;
    }

    // 检查是否已解锁
    function isUnlocked() external view returns (bool) {
        return block.timestamp >= unlockTime;
    }

    // 获取剩余锁定时间
    function getRemainingLockTime() external view returns (uint256) {
        if (block.timestamp >= unlockTime) {
            return 0;
        }
        return unlockTime - block.timestamp;
    }

    function getBoxType() external pure override returns (string memory) {
        return "TimeLocked";
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./day11_Ownable.sol";

/**
 * @title VaultMaster - 金库管理合约
 * @notice 继承 Ownable，展示继承的使用
 * @dev 核心知识点：合约继承、payable、提现模式
 */
contract VaultMaster is Ownable {

    uint256 public treasureAmount;

    // 存入资金
    function depositTreasure() public payable {
        treasureAmount += msg.value;
    }

    // 提取资金（只有 owner 可以）
    function withdrawTreasure(uint256 _amount) public onlyOwner {
        require(_amount <= treasureAmount, "Insufficient treasure");
        require(_amount <= address(this).balance, "Insufficient balance");

        treasureAmount -= _amount;

        (bool success, ) = payable(msg.sender).call{value: _amount}("");
        require(success, "Transfer failed");
    }

    // 获取合约余额
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}

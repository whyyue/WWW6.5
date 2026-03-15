// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./day14_IDepositBox.sol";
import "./day14_BasicDepositBox.sol";
import "./day14_PremiumDepositBox.sol";
import "./day14_TimeLockedDepositBox.sol";

/**
 * @title VaultManager - 金库管理中心
 * @notice 创建和管理不同类型的金库
 * @dev 核心知识点：工厂模式、合约创建、多合约协作
 */
contract VaultManager {

    // 记录每个用户拥有的所有金库地址
    mapping(address => address[]) private userDepositBoxes;

    // 金库地址 => 金库名称
    mapping(address => string) private boxNames;

    // 当创建金库时触发
    event BoxCreated(address indexed owner, address indexed boxAddress, string boxType);

    // 当给金库命名时触发
    event BoxNamed(address indexed boxAddress, string name);

    // 创建 Basic 类型金库
    function createBasicBox() external returns (address) {
        // 部署一个新的 BasicDepositBox
        BasicDepositBox box = new BasicDepositBox();

        // 记录到用户的金库列表
        userDepositBoxes[msg.sender].push(address(box));

        // 触发事件
        emit BoxCreated(msg.sender, address(box), "Basic");

        return address(box);
    }

    // 创建 Premium 类型金库
    function createPremiumBox() external returns (address) {
        PremiumDepositBox box = new PremiumDepositBox();

        userDepositBoxes[msg.sender].push(address(box));

        emit BoxCreated(msg.sender, address(box), "Premium");

        return address(box);
    }

    // 创建带时间锁的金库
    function createTimeLockedBox(uint256 lockDuration) external returns (address) {
        TimeLockedDepositBox box = new TimeLockedDepositBox(lockDuration);

        userDepositBoxes[msg.sender].push(address(box));

        emit BoxCreated(msg.sender, address(box), "TimeLocked");

        return address(box);
    }

    // 给金库设置名称
    function nameBox(address boxAddress, string memory name) external {
        IDepositBox box = IDepositBox(boxAddress);

        // 确保调用者是金库 owner
        require(box.getOwner() == msg.sender, "Not the box owner");

        boxNames[boxAddress] = name;

        emit BoxNamed(boxAddress, name);
    }

    // 通过 Manager 存储 secret
    function storeSecret(address boxAddress, string calldata secret) external {
        IDepositBox box = IDepositBox(boxAddress);

        require(box.getOwner() == msg.sender, "Not the box owner");

        box.storeSecret(secret);
    }

    // 转移金库所有权
    function transferBoxOwnership(address boxAddress, address newOwner) external {
        IDepositBox box = IDepositBox(boxAddress);

        require(box.getOwner() == msg.sender, "Not the box owner");

        // 调用金库合约转移 owner
        box.transferOwnership(newOwner);

        // 更新 Manager 中的用户金库记录
        address[] storage boxes = userDepositBoxes[msg.sender];

        for (uint i = 0; i < boxes.length; i++) {
            if (boxes[i] == boxAddress) {
                // swap + pop 删除数组元素
                boxes[i] = boxes[boxes.length - 1];
                boxes.pop();
                break;
            }
        }

        // 添加到新 owner
        userDepositBoxes[newOwner].push(boxAddress);
    }

    // 获取某个用户的所有金库
    function getUserBoxes(address user) external view returns (address[] memory) {
        return userDepositBoxes[user];
    }

    // 获取金库名称
    function getBoxName(address boxAddress) external view returns (string memory) {
        return boxNames[boxAddress];
    }

    // 获取金库完整信息
    function getBoxInfo(address boxAddress)
        external
        view
        returns (
            string memory boxType,
            address owner,
            uint256 depositTime,
            string memory name
        )
    {
        IDepositBox box = IDepositBox(boxAddress);

        return (
            box.getBoxType(),
            box.getOwner(),
            box.getDepositTime(),
            boxNames[boxAddress]
        );
    }
}

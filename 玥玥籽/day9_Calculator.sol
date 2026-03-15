// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./day9_ScientificCalculator.sol";

/**
 * @title Calculator - 主计算器合约
 * @notice 基础运算 + 调用外部科学计算器
 * @dev 核心知识点：合约间调用、import、高级调用 vs 低级调用
 */
contract Calculator {

    address public owner;
    address public scientificCalculatorAddress;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can do this action");
        _;
    }

    // 设置 ScientificCalculator 合约地址
    function setScientificCalculator(address _address) public onlyOwner {
        scientificCalculatorAddress = _address;
    }

    // 加法
    function add(uint256 a, uint256 b) public pure returns (uint256) {
        return a + b;
    }

    // 减法
    function subtract(uint256 a, uint256 b) public pure returns (uint256) {
        return a - b;
    }

    // 乘法
    function multiply(uint256 a, uint256 b) public pure returns (uint256) {
        return a * b;
    }

    // 除法
    function divide(uint256 a, uint256 b) public pure returns (uint256) {
        require(b != 0, "Cannot divide by zero");
        return a / b;
    }

    // 调用 ScientificCalculator 的 power 函数（高级调用）
    function calculatePower(uint256 base, uint256 exponent) public view returns (uint256) {
        // 创建 ScientificCalculator 实例
        ScientificCalculator scientificCalc = ScientificCalculator(scientificCalculatorAddress);

        // 调用外部合约函数
        uint256 result = scientificCalc.power(base, exponent);

        return result;
    }

    // 使用 low-level call 调用 squareRoot（低级调用）
    function calculateSquareRoot(uint256 number) public returns (uint256) {
        // 编码函数调用
        bytes memory data = abi.encodeWithSignature("squareRoot(uint256)", number);

        // 调用外部合约
        (bool success, bytes memory returnData) = scientificCalculatorAddress.call(data);

        // 如果调用失败则回滚
        require(success, "External call failed");

        // 解码返回值
        uint256 result = abi.decode(returnData, (uint256));

        return result;
    }
}

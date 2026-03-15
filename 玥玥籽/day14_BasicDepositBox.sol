// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./day14_BaseDepositBox.sol";

/**
 * @title BasicDepositBox - 基础金库
 * @notice 最简单的金库类型，没有额外功能
 */
contract BasicDepositBox is BaseDepositBox {

    function getBoxType() external pure override returns (string memory) {
        return "Basic";
    }
}

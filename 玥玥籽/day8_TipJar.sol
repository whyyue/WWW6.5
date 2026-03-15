// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title TipJar - 多货币打赏罐
 * @notice 支持多种货币的打赏系统，自动转换为 ETH
 * @dev 核心知识点：货币转换、mapping 嵌套、keccak256 字符串比较
 */
contract TipJar {
    address public owner;
    uint256 public totalTipsReceived;

    // 货币代码 => 转换率（1 单位货币 = 多少 wei）
    mapping(string => uint256) public conversionRates;

    // 记录每个地址的打赏总额（以 wei 计）
    mapping(address => uint256) public tipPerPerson;

    // 支持的货币列表
    string[] public supportedCurrencies;

    // 记录每种货币收到的打赏数量
    mapping(string => uint256) public tipsPerCurrency;

    constructor() {
        owner = msg.sender;

        // 初始化支持的货币及汇率
        // 1 USD = 0.0005 ETH = 5 * 10^14 wei
        addCurrency("USD", 5 * 10**14);
        addCurrency("EUR", 6 * 10**14);
        addCurrency("JPY", 4 * 10**12);
        addCurrency("INR", 7 * 10**12);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    // 添加或更新支持的货币
    function addCurrency(string memory _currencyCode, uint256 _rateToEth) public onlyOwner {
        require(_rateToEth > 0, "Conversion rate must be greater than 0");

        bool currencyExists = false;

        // 检查货币是否已存在
        for (uint i = 0; i < supportedCurrencies.length; i++) {
            // keccak256 用于比较字符串
            if (keccak256(bytes(supportedCurrencies[i])) == keccak256(bytes(_currencyCode))) {
                currencyExists = true;
                break;
            }
        }

        // 如果是新货币，添加到列表
        if (!currencyExists) {
            supportedCurrencies.push(_currencyCode);
        }

        // 设置或更新汇率
        conversionRates[_currencyCode] = _rateToEth;
    }

    // 将指定货币金额转换为 ETH（wei）
    function convertToEth(string memory _currencyCode, uint256 _amount) public view returns (uint256) {
        require(conversionRates[_currencyCode] > 0, "Currency not supported");
        uint256 ethAmount = _amount * conversionRates[_currencyCode];
        return ethAmount;
    }

    // 直接用 ETH 打赏
    function tipInEth() public payable {
        require(msg.value > 0, "Tip amount must be greater than 0");

        tipPerPerson[msg.sender] += msg.value;
        totalTipsReceived += msg.value;
        tipsPerCurrency["ETH"] += msg.value;
    }

    // 用外币打赏（需要发送等值 ETH）
    function tipInCurrency(string memory _currencyCode, uint256 _amount) public payable {
        require(conversionRates[_currencyCode] > 0, "Currency not supported");
        require(_amount > 0, "Amount must be greater than 0");

        uint256 ethAmount = convertToEth(_currencyCode, _amount);
        require(msg.value == ethAmount, "Sent ETH doesn't match the converted amount");

        tipPerPerson[msg.sender] += msg.value;
        totalTipsReceived += msg.value;
        tipsPerCurrency[_currencyCode] += _amount;
    }

    // 提现所有打赏（只有 owner 可以）
    function withdrawTips() public onlyOwner {
        uint256 contractBalance = address(this).balance;
        require(contractBalance > 0, "No tips to withdraw");

        (bool success, ) = payable(owner).call{value: contractBalance}("");
        require(success, "Transfer failed");

        totalTipsReceived = 0;
    }

    // 转移合约所有权
    function transferOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != address(0), "Invalid address");
        owner = _newOwner;
    }

    // 获取支持的货币列表
    function getSupportedCurrencies() public view returns (string[] memory) {
        return supportedCurrencies;
    }

    // 获取合约当前余额
    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    // 查询某个地址打赏了多少
    function getTipperContribution(address _tipper) public view returns (uint256) {
        return tipPerPerson[_tipper];
    }

    // 查询某种货币收到多少打赏
    function getTipsInCurrency(string memory _currencyCode) public view returns (uint256) {
        return tipsPerCurrency[_currencyCode];
    }

    // 查询某种货币的汇率
    function getConversionRate(string memory _currencyCode) public view returns (uint256) {
        require(conversionRates[_currencyCode] > 0, "Currency not supported");
        return conversionRates[_currencyCode];
    }
}

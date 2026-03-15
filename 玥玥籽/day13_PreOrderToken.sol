// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./day13_MyToken.sol";

/**
 * @title PreOrderToken - 代币预售合约
 * @notice 用户可以用 ETH 购买代币，owner 可以提取 ETH
 * @dev 核心知识点：代币销售、价格计算、payable
 */
contract PreOrderToken {

    MyToken public token;
    address public owner;

    // 代币价格：1 ETH 可以买多少个代币
    uint256 public tokenPrice;

    // 预售是否开启
    bool public saleActive;

    // 记录每个地址购买了多少代币
    mapping(address => uint256) public purchasedTokens;

    // 购买事件
    event TokensPurchased(address indexed buyer, uint256 ethAmount, uint256 tokenAmount);

    // 提现事件
    event EthWithdrawn(address indexed owner, uint256 amount);

    constructor(address _tokenAddress, uint256 _tokenPrice) {
        token = MyToken(_tokenAddress);
        owner = msg.sender;
        tokenPrice = _tokenPrice;
        saleActive = true;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    // 购买代币
    function buyTokens() public payable {
        require(saleActive, "Sale is not active");
        require(msg.value > 0, "Must send ETH to buy tokens");

        // 计算可以购买多少代币
        uint256 tokenAmount = msg.value * tokenPrice;

        // 检查合约是否有足够的代币
        require(token.balanceOf(address(this)) >= tokenAmount, "Not enough tokens in contract");

        // 转移代币给购买者
        token.transfer(msg.sender, tokenAmount);

        // 记录购买量
        purchasedTokens[msg.sender] += tokenAmount;

        // 触发购买事件
        emit TokensPurchased(msg.sender, msg.value, tokenAmount);
    }

    // 设置代币价格
    function setTokenPrice(uint256 _newPrice) public onlyOwner {
        tokenPrice = _newPrice;
    }

    // 开启/关闭预售
    function setSaleActive(bool _active) public onlyOwner {
        saleActive = _active;
    }

    // 提取 ETH
    function withdrawEth() public onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No ETH to withdraw");

        (bool success, ) = payable(owner).call{value: balance}("");
        require(success, "Transfer failed");

        emit EthWithdrawn(owner, balance);
    }

    // 提取剩余代币
    function withdrawTokens() public onlyOwner {
        uint256 balance = token.balanceOf(address(this));
        require(balance > 0, "No tokens to withdraw");

        token.transfer(owner, balance);
    }

    // 获取合约的代币余额
    function getTokenBalance() public view returns (uint256) {
        return token.balanceOf(address(this));
    }

    // 获取合约的 ETH 余额
    function getEthBalance() public view returns (uint256) {
        return address(this).balance;
    }
}

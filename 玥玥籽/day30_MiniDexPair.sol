// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract MiniDexPair is ERC20, ReentrancyGuard {

    uint256 public constant MINIMUM_LIQUIDITY = 1000;

    address public factory;
    address public token0;
    address public token1;

    uint256 public reserve0;
    uint256 public reserve1;

    event LiquidityAdded(address indexed provider, uint256 amount0, uint256 amount1, uint256 liquidity);
    event LiquidityRemoved(address indexed provider, uint256 amount0, uint256 amount1, uint256 liquidity);
    event Swap(address indexed trader, address tokenIn, uint256 amountIn, address tokenOut, uint256 amountOut);

    modifier onlyFactory() {
        require(msg.sender == factory, "Only factory");
        _;
    }

    constructor() ERC20("MiniDex LP Token", "MLP") {
        factory = msg.sender;
    }

    function initialize(address _token0, address _token1) external onlyFactory {
        require(token0 == address(0), "Already initialized");
        token0 = _token0;
        token1 = _token1;
    }

    function addLiquidity(uint256 amount0, uint256 amount1) external nonReentrant returns (uint256 liquidity) {
        require(amount0 > 0 && amount1 > 0, "Amounts must be > 0");

        IERC20(token0).transferFrom(msg.sender, address(this), amount0);
        IERC20(token1).transferFrom(msg.sender, address(this), amount1);

        uint256 _totalSupply = totalSupply();

        if (_totalSupply == 0) {
            liquidity = sqrt(amount0 * amount1) - MINIMUM_LIQUIDITY;
            _mint(address(0), MINIMUM_LIQUIDITY);
        } else {
            liquidity = min(
                amount0 * _totalSupply / reserve0,
                amount1 * _totalSupply / reserve1
            );
        }

        require(liquidity > 0, "Insufficient liquidity minted");
        _mint(msg.sender, liquidity);

        reserve0 += amount0;
        reserve1 += amount1;

        emit LiquidityAdded(msg.sender, amount0, amount1, liquidity);
    }

    function removeLiquidity(uint256 liquidity) external nonReentrant returns (uint256 amount0Out, uint256 amount1Out) {
        require(liquidity > 0, "Must remove positive liquidity");
        require(balanceOf(msg.sender) >= liquidity, "Insufficient LP tokens");

        uint256 _totalSupply = totalSupply();
        amount0Out = liquidity * reserve0 / _totalSupply;
        amount1Out = liquidity * reserve1 / _totalSupply;

        require(amount0Out > 0 && amount1Out > 0, "Insufficient output");

        _burn(msg.sender, liquidity);
        reserve0 -= amount0Out;
        reserve1 -= amount1Out;

        IERC20(token0).transfer(msg.sender, amount0Out);
        IERC20(token1).transfer(msg.sender, amount1Out);

        emit LiquidityRemoved(msg.sender, amount0Out, amount1Out, liquidity);
    }

    function swap(address tokenIn, uint256 amountIn, uint256 minAmountOut) external nonReentrant returns (uint256 amountOut) {
        require(tokenIn == token0 || tokenIn == token1, "Invalid token");
        require(amountIn > 0, "Amount must be > 0");
        require(reserve0 > 0 && reserve1 > 0, "No liquidity");

        bool isToken0In = tokenIn == token0;
        (uint256 reserveIn, uint256 reserveOut, address tokenOut) = isToken0In
            ? (reserve0, reserve1, token1)
            : (reserve1, reserve0, token0);

        amountOut = getAmountOut(amountIn, reserveIn, reserveOut);
        require(amountOut >= minAmountOut, "Slippage too high");

        IERC20(tokenIn).transferFrom(msg.sender, address(this), amountIn);
        IERC20(tokenOut).transfer(msg.sender, amountOut);

        uint256 amountInWithFee = amountIn * 997 / 1000;
        if (isToken0In) {
            reserve0 += amountInWithFee;
            reserve1 -= amountOut;
        } else {
            reserve1 += amountInWithFee;
            reserve0 -= amountOut;
        }

        emit Swap(msg.sender, tokenIn, amountIn, tokenOut, amountOut);
    }

    // amountOut = reserveOut * amountIn * 997 / (reserveIn * 1000 + amountIn * 997)
    function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut) public pure returns (uint256) {
        require(amountIn > 0 && reserveIn > 0 && reserveOut > 0, "Invalid inputs");
        uint256 amountInWithFee = amountIn * 997;
        return (reserveOut * amountInWithFee) / (reserveIn * 1000 + amountInWithFee);
    }

    function getReserves() external view returns (uint256, uint256) {
        return (reserve0, reserve1);
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}

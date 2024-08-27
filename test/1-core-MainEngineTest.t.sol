// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {MainEngine} from "../src/MainEngine.sol";
import {DeployMainEngine} from "../script/DeployMainEngine.s.sol";
import {CustomToken} from "../src/CustomToken.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IUniswapV3Pool} from "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import {IUniswapV3Factory} from "@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol";

contract MainEngineTest is Test {
    MainEngine public mainEngine;
    address public deployer;
    address public user;
    address public WETH9;
    DeployMainEngine.DeploymentInfo public deploymentInfo;

    function setUp() public {
        deployer = makeAddr("deployer");
        user = makeAddr("user");
        
        DeployMainEngine deployScript = new DeployMainEngine();
        (mainEngine, deploymentInfo) = deployScript.run();
        
        WETH9 = deploymentInfo.WETH9;
        
        console.log("MainEngine deployed at:", address(mainEngine));
    }

    function testSetupPool() public {
        vm.startPrank(user);
        vm.deal(user, 1 ether);

        // Step 1: Create a token
        (address tokenAddress, CustomToken token) = createTestToken();

        // Step 2: Setup pool
        mainEngine.testPoolSetup(tokenAddress);

        // Step 3: Verify pool setup
        address poolAddress = mainEngine.getTokenToPool(tokenAddress);
        assertTrue(poolAddress != address(0), "Pool not created");

        IUniswapV3Pool pool = IUniswapV3Pool(poolAddress);
        assertEq(pool.token0(), tokenAddress, "Incorrect token0");
        assertEq(pool.token1(), WETH9, "Incorrect token1");
        assertEq(pool.fee(), mainEngine.poolFee(), "Incorrect pool fee");

        // Verify event emission
        vm.expectEmit(true, true, false, true);
        emit MainEngine.PoolCreated(tokenAddress, poolAddress);

        vm.stopPrank();
    }

    function testAddInitialLiquidity() public {
        vm.startPrank(user);
        vm.deal(user, 10 ether);

        // Step 1: Create a token
        (address tokenAddress, CustomToken token) = createTestToken();

        // Step 2: Setup pool
        mainEngine.testPoolSetup(tokenAddress);

        // Step 3: Add initial liquidity
        uint256 tokenAmount = 1_000_000 * 1e18;
        uint256 ethAmount = 1 ether;

        token.approve(address(mainEngine), tokenAmount);

        uint256 initialTokenBalance = token.balanceOf(address(mainEngine));
        uint256 initialEthBalance = address(mainEngine).balance;

        mainEngine.testAddInitialLiquidity{value: ethAmount}(tokenAddress, tokenAmount);

        // Step 4: Verify liquidity addition
        assertTrue(mainEngine.getInitialLiquidityAdded(tokenAddress), "Initial liquidity not marked as added");
        assertEq(token.balanceOf(address(mainEngine)), initialTokenBalance + tokenAmount, "Token balance not increased");
        assertEq(address(mainEngine).balance, initialEthBalance + ethAmount, "ETH balance not increased");

        uint256 positionId = mainEngine.getTokenToPositionId(tokenAddress);
        assertTrue(positionId > 0, "Position ID not set");

        uint256 liquidity = mainEngine.getTokenToLiquidity(tokenAddress);
        assertTrue(liquidity > 0, "Liquidity not added");

        uint256 withdrawableLiquidity = mainEngine.getTokenToWithdrawableLiquidity(tokenAddress);
        assertTrue(withdrawableLiquidity > 0, "Withdrawable liquidity not set");

        // Verify event emission
        vm.expectEmit(true, true, false, true);
        emit MainEngine.LiquidityAdded(tokenAddress, user, liquidity);

        vm.stopPrank();
    }

    function createTestToken() internal returns (address tokenAddress, CustomToken token) {
        string memory name = "Test Token";
        string memory symbol = "TST";
        string memory description = "A test token";
        string memory imageUrl = "https://example.com/image.png";
        uint256 initialSupply = 1_000_000 * 1e18; // 1 million tokens

        tokenAddress = mainEngine.createTokenOnly(
            name,
            symbol,
            description,
            imageUrl,
            initialSupply
        );

        token = CustomToken(tokenAddress);

        // Verify token creation
        assertEq(token.name(), name, "Token name mismatch");
        assertEq(token.symbol(), symbol, "Token symbol mismatch");
        assertEq(token.getDescription(), description, "Token description mismatch");
        assertEq(token.getImageUrl(), imageUrl, "Token image URL mismatch");
        assertEq(token.totalSupply(), initialSupply, "Token initial supply mismatch");
        assertEq(token.balanceOf(user), initialSupply, "User balance mismatch");

        assertTrue(mainEngine.isTokenCreated(tokenAddress), "Token not marked as created");
        assertEq(mainEngine.tokenCreator(tokenAddress), user, "Token creator mismatch");

        return (tokenAddress, token);
    }
    function testFactoryCreatePool() public {
    address token0 = address(0x1111111111111111111111111111111111111111);
    address token1 = address(0x2222222222222222222222222222222222222222);
    uint24 fee = 3000;

    IUniswapV3Factory factory = IUniswapV3Factory(mainEngine.factory());
    
    address pool = factory.createPool(token0, token1, fee);
    assertTrue(pool != address(0), "Pool creation failed");
}
}
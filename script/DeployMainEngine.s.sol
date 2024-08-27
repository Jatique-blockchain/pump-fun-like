// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {MainEngine} from "../src/MainEngine.sol";
import {IUniswapV3Factory} from "@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol";
import {UniswapV3Factory} from "@uniswap/v3-core/contracts/UniswapV3Factory.sol";
import {INonfungiblePositionManager} from "@uniswap/v3-periphery/contracts/interfaces/INonfungiblePositionManager.sol";
import {NonfungiblePositionManager} from "@uniswap/v3-periphery/contracts/NonfungiblePositionManager.sol";
import {ISwapRouter} from "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import {SwapRouter} from "@uniswap/v3-periphery/contracts/SwapRouter.sol";
import {NonfungibleTokenPositionDescriptor} from
    "@uniswap/v3-periphery/contracts/NonfungibleTokenPositionDescriptor.sol";
import {WETH9} from "./WETH9.sol";
import {
  abi as SWAP_ROUTER_ABI,
  bytecode as SWAP_ROUTER_BYTECODE,
} from '@uniswap/v3-periphery/artifacts/contracts/SwapRouter.sol/SwapRouter.json';

struct DeploymentInfo {
    address factory;
    address nonfungiblePositionManager;
    address swapRouter;
    address WETH9;
    address tokenDescriptor;
    uint256 chainId;
}

contract DeployMainEngine is Script {
    function run() external returns (MainEngine, DeploymentInfo memory) {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        DeploymentInfo memory info;
        info.chainId = block.chainid;

        if (info.chainId == 31337) {
            // Anvil
            // Deploy WETH9
            WETH9 weth9 = new WETH9();
            info.WETH9 = address(weth9);

            // Deploy UniswapV3Factory
            UniswapV3Factory uniswapFactory = new UniswapV3Factory();
            info.factory = address(uniswapFactory);

            // Deploy NonfungibleTokenPositionDescriptor
            bytes32 nativeCurrencyLabelBytes = bytes32("ETH");
            NonfungibleTokenPositionDescriptor tokenDescriptor =
                new NonfungibleTokenPositionDescriptor(info.WETH9, nativeCurrencyLabelBytes);
            info.tokenDescriptor = address(tokenDescriptor);

            // Deploy NonfungiblePositionManager
            NonfungiblePositionManager nonfungiblePositionManager =
                new NonfungiblePositionManager(info.factory, info.WETH9, info.tokenDescriptor);
            info.nonfungiblePositionManager = address(nonfungiblePositionManager);

            // Deploy SwapRouter
            SwapRouter swapRouter = new SwapRouter(info.factory, info.WETH9);
            info.swapRouter = address(swapRouter);
        } else if (info.chainId == 11155111) {
            // Sepolia
            info.factory = address(0x1F98431c8aD98523631AE4a59f267346ea31F984);
            info.nonfungiblePositionManager = address(0xC36442b4a4522E871399CD717aBDD847Ab11FE88);
            info.swapRouter = address(0xE592427A0AEce92De3Edee1F18E0157C05861564);
            info.WETH9 = address(0xfFf9976782d46CC05630D1f6eBAb18b2324d6B14);
            info.tokenDescriptor = address(0x42B24A95702b9986e82d421cC3568932790A48Ec); // Example Sepolia address
        } else {
            revert("Unsupported chain ID");
        }

        // Deploy MainEngine
        MainEngine mainEngine = new MainEngine(
            IUniswapV3Factory(info.factory),
            INonfungiblePositionManager(info.nonfungiblePositionManager),
            ISwapRouter(info.swapRouter),
            info.WETH9
        );

        console.log("MainEngine deployed at:", address(mainEngine));
        console.log("Using Factory:", info.factory);
        console.log("Using NonfungiblePositionManager:", info.nonfungiblePositionManager);
        console.log("Using SwapRouter:", info.swapRouter);
        console.log("Using WETH9:", info.WETH9);
        console.log("Using TokenDescriptor:", info.tokenDescriptor);
        console.log("Chain ID:", info.chainId);

        vm.stopBroadcast();

        return (mainEngine, info);
    }
}

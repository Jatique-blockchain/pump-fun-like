// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {MainEngine} from "../src/MainEngine.sol";
import {IUniswapV3Factory} from "@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol";
import {INonfungiblePositionManager} from "@uniswap/v3-periphery/contracts/interfaces/INonfungiblePositionManager.sol";
import {ISwapRouter} from "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import {WETH9} from "../test/mocks/Weth9Mock.sol";
import {UniswapV3Factory} from "@uniswap/v3-core/contracts/UniswapV3Factory.sol";
import {NonfungibleTokenPositionDescriptor} from "@uniswap/v3-periphery/contracts/NonfungibleTokenPositionDescriptor.sol";
import {NonfungiblePositionManager} from "@uniswap/v3-periphery/contracts/NonfungiblePositionManager.sol";
import {SwapRouter} from "@uniswap/v3-periphery/contracts/SwapRouter.sol";

contract DeployMainEngine is Script {
    struct DeploymentInfo {
        address factory;
        address nonfungiblePositionManager;
        address swapRouter;
        address WETH9;
        address tokenDescriptor;
        uint256 chainId;
    }

    DeploymentInfo public info;

    function run() external returns (MainEngine, DeploymentInfo memory) {
        console.log("Starting DeployMainEngine script");

        info.chainId = block.chainid;
        console.log("Chain ID:", info.chainId);

        uint256 deployerPrivateKey;
        if (info.chainId == 31337) {
            deployerPrivateKey = vm.envUint("ANVIL_PRIVATE_KEY");
            console.log("Using Anvil private key");
        } else if (info.chainId == 11155111) {
            deployerPrivateKey = vm.envUint("SEPOLIA_PRIVATE_KEY");
            console.log("Using Sepolia private key");
        } else {
            revert("Unsupported chain ID");
        }

        vm.startBroadcast(deployerPrivateKey);

        if (info.chainId == 31337) {
            deployAnvilContracts();
        } else if (info.chainId == 11155111) {
            setSepoliaAddresses();
        }

        MainEngine mainEngine = new MainEngine(
            IUniswapV3Factory(info.factory),
            INonfungiblePositionManager(info.nonfungiblePositionManager),
            ISwapRouter(info.swapRouter),
            info.WETH9
        );
        console.log("MainEngine deployed at:", address(mainEngine));

        logDeploymentInfo();

        vm.stopBroadcast();
        console.log("DeployMainEngine script completed");
        return (mainEngine, info);
    }

    function deployAnvilContracts() internal {
        console.log("Deploying on Anvil (Chain ID: 31337)");

        WETH9 weth9 = new WETH9();
        info.WETH9 = address(weth9);

        UniswapV3Factory factory = new UniswapV3Factory();
        info.factory = address(factory);

        bytes32 nativeCurrencyLabelBytes = bytes32("ETH");
        NonfungibleTokenPositionDescriptor tokenDescriptor = new NonfungibleTokenPositionDescriptor(
            info.WETH9,
            nativeCurrencyLabelBytes
        );
        info.tokenDescriptor = address(tokenDescriptor);

        NonfungiblePositionManager nonfungiblePositionManager = new NonfungiblePositionManager(
            info.factory,
            info.WETH9,
            info.tokenDescriptor
        );
        info.nonfungiblePositionManager = address(nonfungiblePositionManager);

        SwapRouter swapRouter = new SwapRouter(info.factory, info.WETH9);
        info.swapRouter = address(swapRouter);
    }

    function setSepoliaAddresses() internal {
        console.log("Using predefined addresses for Sepolia (Chain ID: 11155111)");
        info.factory = address(0x1F98431c8aD98523631AE4a59f267346ea31F984);
        info.nonfungiblePositionManager = address(0xC36442b4a4522E871399CD717aBDD847Ab11FE88);
        info.swapRouter = address(0xE592427A0AEce92De3Edee1F18E0157C05861564);
        info.WETH9 = address(0xfFf9976782d46CC05630D1f6eBAb18b2324d6B14);
        info.tokenDescriptor = address(0x42B24A95702b9986e82d421cC3568932790A48Ec);
    }

    function logDeploymentInfo() internal view {
        console.log("Deployment Info:");
        console.log("- Factory:", info.factory);
        console.log("- NonfungiblePositionManager:", info.nonfungiblePositionManager);
        console.log("- SwapRouter:", info.swapRouter);
        console.log("- WETH9:", info.WETH9);
        console.log("- TokenDescriptor:", info.tokenDescriptor);
        console.log("- Chain ID:", info.chainId);
    }
}
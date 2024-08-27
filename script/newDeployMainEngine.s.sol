// // SPDX-License-Identifier: UNLICENSED
// pragma solidity ^0.8.19;

// import {Script} from "forge-std/Script.sol";
// import {console} from "forge-std/console.sol";
// import {MainEngine} from "../src/MainEngine.sol";
// import {IUniswapV3Factory} from "@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol";
// import {INonfungiblePositionManager} from "@uniswap/v3-periphery/contracts/interfaces/INonfungiblePositionManager.sol";
// import {ISwapRouter} from "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
// import {WETH9} from "../test/mocks/Weth9Mock.sol";

// import {
//     abi as FACTORY_ABI,
//     bytecode as FACTORY_BYTECODE
// } from "@uniswap/v3-core/artifacts/contracts/UniswapV3Factory.sol/UniswapV3Factory.json";
// import {
//     abi as POSITION_MANAGER_ABI,
//     bytecode as POSITION_MANAGER_BYTECODE
// } from "@uniswap/v3-periphery/artifacts/contracts/NonfungiblePositionManager.sol/NonfungiblePositionManager.json";
// import {
//     abi as SWAP_ROUTER_ABI,
//     bytecode as SWAP_ROUTER_BYTECODE
// } from "@uniswap/v3-periphery/artifacts/contracts/SwapRouter.sol/SwapRouter.json";
// import {
//     abi as DESCRIPTOR_ABI,
//     bytecode as DESCRIPTOR_BYTECODE
// } from
//     "@uniswap/v3-periphery/artifacts/contracts/NonfungibleTokenPositionDescriptor.sol/NonfungibleTokenPositionDescriptor.json";

// struct DeploymentInfo {
//     address factory;
//     address nonfungiblePositionManager;
//     address swapRouter;
//     address WETH9;
//     address tokenDescriptor;
//     uint256 chainId;
// }

// contract DeployMainEngine is Script {
//     function run() external returns (MainEngine, DeploymentInfo memory) {
//         uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
//         vm.startBroadcast(deployerPrivateKey);

//         DeploymentInfo memory info;
//         info.chainId = block.chainid;

//         if (info.chainId == 31337) {
//             // Anvil
//             // Deploy WETH9
//             WETH9 weth9 = new WETH9();
//             info.WETH9 = address(weth9);

//             // Deploy UniswapV3Factory
//             info.factory = deployContract(FACTORY_BYTECODE, abi.encode());

//             // Deploy NonfungibleTokenPositionDescriptor
//             bytes32 nativeCurrencyLabelBytes = bytes32("ETH");
//             info.tokenDescriptor = deployContract(DESCRIPTOR_BYTECODE, abi.encode(info.WETH9, nativeCurrencyLabelBytes));

//             // Deploy NonfungiblePositionManager
//             info.nonfungiblePositionManager =
//                 deployContract(POSITION_MANAGER_BYTECODE, abi.encode(info.factory, info.WETH9, info.tokenDescriptor));

//             // Deploy SwapRouter
//             info.swapRouter = deployContract(SWAP_ROUTER_BYTECODE, abi.encode(info.factory, info.WETH9));
//         } else if (info.chainId == 11155111) {
//             // Sepolia
//             info.factory = address(0x1F98431c8aD98523631AE4a59f267346ea31F984);
//             info.nonfungiblePositionManager = address(0xC36442b4a4522E871399CD717aBDD847Ab11FE88);
//             info.swapRouter = address(0xE592427A0AEce92De3Edee1F18E0157C05861564);
//             info.WETH9 = address(0xfFf9976782d46CC05630D1f6eBAb18b2324d6B14);
//             info.tokenDescriptor = address(0x42B24A95702b9986e82d421cC3568932790A48Ec);
//         } else {
//             revert("Unsupported chain ID");
//         }

//         // Deploy MainEngine
//         MainEngine mainEngine = new MainEngine(
//             IUniswapV3Factory(info.factory),
//             INonfungiblePositionManager(info.nonfungiblePositionManager),
//             ISwapRouter(info.swapRouter),
//             info.WETH9
//         );

//         console.log("MainEngine deployed at:", address(mainEngine));
//         console.log("Using Factory:", info.factory);
//         console.log("Using NonfungiblePositionManager:", info.nonfungiblePositionManager);
//         console.log("Using SwapRouter:", info.swapRouter);
//         console.log("Using WETH9:", info.WETH9);
//         console.log("Using TokenDescriptor:", info.tokenDescriptor);
//         console.log("Chain ID:", info.chainId);

//         vm.stopBroadcast();

//         return (mainEngine, info);
//     }

//     function deployContract(bytes memory bytecode, bytes memory args) internal returns (address) {
//         address deployedAddress;
//         assembly {
//             deployedAddress := create(0, add(bytecode, 0x20), mload(bytecode))
//             if iszero(deployedAddress) { revert(0, 0) }
//         }

//         if (args.length > 0) {
//             (bool success,) = deployedAddress.call(args);
//             require(success, "Constructor call failed");
//         }

//         return deployedAddress;
//     }
// }

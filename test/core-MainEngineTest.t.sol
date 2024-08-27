// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {MainEngine} from "../src/MainEngine.sol";
import {DeployMainEngine} from "../script/DeployMainEngine.s.sol";
import {CustomToken} from "../src/CustomToken.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MainEngineTest is Test {
    MainEngine public mainEngine;
    address public deployer;
    address public user;

    function setUp() public {
        deployer = makeAddr("deployer");
        user = makeAddr("user");
        
        DeployMainEngine deployScript = new DeployMainEngine();
        (mainEngine,) = deployScript.run();
        
        console.log("MainEngine deployed at:", address(mainEngine));
    }

    function testCreateToken() public {
        vm.startPrank(user);
        vm.deal(user, 1 ether); // Give the user some ETH

        console.log("Starting token creation test with user:", user);
        console.log("User ETH balance:", user.balance);

        string memory name = "Test Token";
        string memory symbol = "TST";
        string memory description = "A test token";
        string memory imageUrl = "https://example.com/image.png";
        uint256 initialSupply = 1_000_000 * 1e18; // 1 million tokens

        console.log("Attempting to create token with following parameters:");
        console.log("Name:", name);
        console.log("Symbol:", symbol);
        console.log("Description:", description);
        console.log("Image URL:", imageUrl);
        console.log("Initial Supply:", initialSupply);

        address tokenAddress = mainEngine.createTokenOnly(
            name,
            symbol,
            description,
            imageUrl,
            initialSupply
        );

        console.log("Token created at address:", tokenAddress);

        // Verify token creation
        CustomToken token = CustomToken(tokenAddress);
        
        console.log("Verifying token properties:");
        console.log("Expected name:", name);
        console.log("Actual name:", token.name());
        assertEq(token.name(), name, "Token name mismatch");

        console.log("Expected symbol:", symbol);
        console.log("Actual symbol:", token.symbol());
        assertEq(token.symbol(), symbol, "Token symbol mismatch");

        console.log("Expected description:", description);
        console.log("Actual description:", token.getDescription());
        assertEq(token.getDescription(), description, "Token description mismatch");

        console.log("Expected image URL:", imageUrl);
        console.log("Actual image URL:", token.getImageUrl());
        assertEq(token.getImageUrl(), imageUrl, "Token image URL mismatch");

        console.log("Expected total supply:", initialSupply);
        console.log("Actual total supply:", token.totalSupply());
        assertEq(token.totalSupply(), initialSupply, "Token initial supply mismatch");

        console.log("Expected user balance:", initialSupply);
        console.log("Actual user balance:", token.balanceOf(user));
        assertEq(token.balanceOf(user), initialSupply, "User balance mismatch");

        // Verify MainEngine state
        console.log("Verifying MainEngine state:");
        
        console.log("Is token created? Expected: true, Actual:", mainEngine.isTokenCreated(tokenAddress));
        assertTrue(mainEngine.isTokenCreated(tokenAddress), "Token not marked as created");

        console.log("Token creator. Expected:", user);
        console.log("Token creator. Actual:", mainEngine.tokenCreator(tokenAddress));
        assertEq(mainEngine.tokenCreator(tokenAddress), user, "Token creator mismatch");

        vm.stopPrank();
        console.log("Token creation test completed successfully");
    }
}
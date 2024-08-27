// pragma solidity ^0.8.19;

// import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
// import {ERC20Burnable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
// import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

// /// @title CustomToken
// /// @notice This contract implements a custom ERC20 token with additional metadata
// contract CustomToken is ERC20, ERC20Burnable, Ownable {
//     string private _description;
//     string private _imageUrl;
//     address public immutable mainEngineAddress;

//     constructor(
//         string memory name,
//         string memory symbol,
//         string memory description,
//         string memory imageUrl,
//         address _mainEngineAddress,
//         uint256 initialSupply
//     ) ERC20(name, symbol) Ownable(_mainEngineAddress) {
//         _description = description;
//         _imageUrl = imageUrl;
//         mainEngineAddress = _mainEngineAddress;

//         _mint(mainEngineAddress, initialSupply);
//     }

//     /// @notice Returns the description of the token
//     function getDescription() public view returns (string memory) {
//         return _description;
//     }

//     /// @notice Returns the image URL of the token
//     function getImageUrl() public view returns (string memory) {
//         return _imageUrl;
//     }

//     /// @notice Mints new tokens
//     /// @dev Only the owner (MainEngine) can call this function
//     /// @param to The address that will receive the minted tokens
//     /// @param amount The amount of tokens to mint
//     function mint(address to, uint256 amount) public onlyOwner {
//         _mint(to, amount);
//     }
// }

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Burnable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/// @title CustomToken
/// @notice This contract implements a custom ERC20 token with additional metadata
contract CustomToken is ERC20, ERC20Burnable, Ownable {
    string private _description;
    string private _imageUrl;
    address public immutable mainEngineAddress;

    constructor(
        string memory name,
        string memory symbol,
        string memory description,
        string memory imageUrl,
        address creator,
        uint256 initialSupply
    ) ERC20(name, symbol) Ownable(creator) {
        _description = description;
        _imageUrl = imageUrl;
        mainEngineAddress = msg.sender; // This should be the MainEngine contract address

        // Mint the initial supply to the creator
        _mint(creator, initialSupply);
    }

    /// @notice Returns the description of the token
    function getDescription() public view returns (string memory) {
        return _description;
    }

    /// @notice Returns the image URL of the token
    function getImageUrl() public view returns (string memory) {
        return _imageUrl;
    }

    /// @notice Mints new tokens
    /// @dev Only the owner can call this function
    /// @param to The address that will receive the minted tokens
    /// @param amount The amount of tokens to mint
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}

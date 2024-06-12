// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import "@openzeppelin/contracts/utils/Context.sol";

contract NextInToken is Context, ERC20, ERC20Burnable, ERC20Pausable, ERC20Capped, Ownable {
    string private _logoURL;
    string private _securityContact = "support@nextinnetworkk.com";

    constructor() 
        ERC20("NextIn", "NIN")
        ERC20Capped(400000000 * 10 ** 18) 
    {
        _mint(msg.sender, 400000000 * 10 ** 18); // Mint the initial supply to the owner
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function setLogoURL(string memory logoURL) public onlyOwner {
        _logoURL = logoURL;
    }

    function getLogoURL() public view returns (string memory) {
        return _logoURL;
    }

    function getSecurityContact() public view returns (string memory) {
        return _securityContact;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal
        whenNotPaused
        override(ERC20, ERC20Capped, ERC20Pausable)
    {
        super._beforeTokenTransfer(from, to, amount);
    }
}

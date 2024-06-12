// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

contract NextInPresale is Ownable, Pausable {
    IERC20 public token;
    uint256 public presalePrice = 0.0375 * 10 ** 18;
    uint256 public publicSalePrice = 0.075 * 10 ** 18;
    uint256 public minInvestment = 0.042 * 10 ** 18; // $10 in BNB (re-evaluate for current rate)
    uint256 public maxInvestment = 2117.10 * 10 ** 18; // $500,000 in BNB
    uint256 public presaleStart;
    uint256 public presaleEnd;
    uint256 public totalCollected;
    uint256 public softcap = 11000000 * 10 ** 18;
    uint256 public hardcap = 15000000 * 10 ** 18;

    struct Vesting {
        uint256 releasePercentage;
        uint256 cyclePeriod;
        uint256 cycleReleasePercentage;
    }

    Vesting public vestingSchedule = Vesting({
        releasePercentage: 20,
        cyclePeriod: 14 days,
        cycleReleasePercentage: 10
    });

    mapping(address => uint256) public investments;
    mapping(address => uint256) public tokenBalances;
    bool public isVestingStarted = false;
    uint256 public vestingStart;
    
    address[] public paymentWallets = [
        0xD78B1B4E3F1A2e6c8Eb603a03D4795CAfEFd2ec8,
        0x7833f9EcC887B9E102f0E50A4C91d15159f6e58c,
        0x2857d489AD12a5d56a7A7C8Ba773466Be01a8539,
        0x0ef703E32AaCE900B5d8237231d6b98717CCeb62,
        0x0E748C86DB7eebe12536A875836d228Ee0b06d7E
    ];

    uint256[] public paymentAmounts = [
        1700000 * 10 ** 18,
        2010000 * 10 ** 18,
        6564115 * 10 ** 18,
        1317500 * 10 ** 18,
        3408385 * 10 ** 18
    ];

    constructor(address _token) {
        token = IERC20(_token);
    }

    function setToken(address _token) public onlyOwner {
        token = IERC20(_token);
    }

    function setPresalePrice(uint256 _price) public onlyOwner {
        presalePrice = _price;
    }

    function setPublicSalePrice(uint256 _price) public onlyOwner {
        publicSalePrice = _price;
    }

    function setPresalePeriod(uint256 _start, uint256 _end) public onlyOwner {
        presaleStart = _start;
        presaleEnd = _end;
    }

    function invest() public payable whenNotPaused {
        require(block.timestamp >= presaleStart && block.timestamp <= presaleEnd, "Presale is not active");
        require(msg.value >= minInvestment && msg.value <= maxInvestment, "Investment amount is out of range");

        uint256 tokenAmount = (msg.value * 10 ** 18) / presalePrice;
        require(totalCollected + tokenAmount <= hardcap, "Hardcap reached");

        investments[msg.sender] += msg.value;
        tokenBalances[msg.sender] += tokenAmount;
        totalCollected += tokenAmount;
    }

    function withdrawFunds() public onlyOwner {
        for (uint256 i = 0; i < paymentWallets.length; i++) {
            payable(paymentWallets[i]).transfer(paymentAmounts[i]);
        }
    }

    function startVesting() public onlyOwner {
        require(!isVestingStarted, "Vesting already started");
        require(block.timestamp > presaleEnd, "Presale not ended yet");
        
        vestingStart = block.timestamp + 14 days;
        isVestingStarted = true;
    }

    function claimTokens() public {
        require(isVestingStarted, "Vesting not started yet");
        require(block.timestamp >= vestingStart, "Vesting period not started yet");

        uint256 vestedAmount = calculateVestedAmount(msg.sender);
        tokenBalances[msg.sender] -= vestedAmount;
        token.transfer(msg.sender, vestedAmount);
    }

    function calculateVestedAmount(address _investor) internal view returns (uint256) {
        uint256 totalVested = (tokenBalances[_investor] * vestingSchedule.releasePercentage) / 100;
        uint256 cycles = (block.timestamp - vestingStart) / vestingSchedule.cyclePeriod;

        for (uint256 i = 0; i < cycles; i++) {
            totalVested += (tokenBalances[_investor] * vestingSchedule.cycleReleasePercentage) / 100;
        }

        return totalVested;
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function withdrawUnsoldTokens() public onlyOwner {
        require(block.timestamp > presaleEnd, "Presale not ended yet");
        uint256 unsoldTokens = token.balanceOf(address(this)) - totalCollected;
        token.transfer(owner(), unsoldTokens);
    }

    function checkBalance() public view returns (uint256) {
        return address(this).balance;
    }
}

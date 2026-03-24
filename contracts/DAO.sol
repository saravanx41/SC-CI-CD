// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title VulnerableBank - Intentionally vulnerable for security testing
/// @notice DO NOT DEPLOY - for Slither/Mythril demo only
contract VulnerableBank {
    mapping(address => uint256) public balances;
    address public owner;

    constructor() {
        owner = tx.origin; // BUG 1: tx.origin instead of msg.sender
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    // BUG 2: Reentrancy - external call before state update
    function withdraw(uint256 amount) public {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        (bool success, ) = msg.sender.call{value: amount}(""); // state NOT updated yet
        require(success, "Transfer failed");
        balances[msg.sender] -= amount; // updated AFTER external call = reentrancy
    }

    // BUG 3: Missing access control - anyone can call
    function emergencyDrain(address payable to) public {
        to.transfer(address(this).balance);
    }

    // BUG 4: Arbitrary send - user-controlled destination
    function sendReward(address payable recipient, uint256 amount) public {
        recipient.transfer(amount);
    }

    receive() external payable {}
}

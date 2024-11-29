// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../lib/forge-std/src/Test.sol";
import "../src/MyERC20.sol";

contract MyERC20Test is Test {
    MyERC20 token;

    address user1 = address(0x1);
    address user2 = address(0x2);

    function setUp() public {
        token = new MyERC20("MyToken", "MTK", 18, 1000);
    }

    function testInitialSupply() public {
        assertEq(token.totalSupply(), 1000 * 10 ** 18);
        assertEq(token.balanceOf(address(this)), 1000 * 10 ** 18);
    }

    function testTransfer() public {
        uint256 amount = 100 * 10 ** 18;

        token.transfer(user1, amount);
        assertEq(token.balanceOf(user1), amount);
        assertEq(token.balanceOf(address(this)), 900 * 10 ** 18);
    }

    function testApproveAndTransferFrom() public {
        uint256 amount = 50 * 10 ** 18;

        // Approve user1 to spend on behalf of this contract
        token.approve(user1, amount);
        vm.prank(user1); // Simulate user1 calling the contract
        token.transferFrom(address(this), user2, amount);

        assertEq(token.balanceOf(user2), amount);
        assertEq(token.balanceOf(address(this)), 950 * 10 ** 18);
        assertEq(token.allowance(address(this), user1), 0);
    }

    function testTransferFailsWithoutBalance() public {
        uint256 amount = 2000 * 10 ** 18;
        vm.expectRevert("Insufficient balance");
        token.transfer(user1, amount);
    }

    function testApproveFailsToZeroAddress() public {
        vm.expectRevert("Approve to zero address");
        token.approve(address(0), 100);
    }

    function testTransferFailsToZeroAddress() public {
        vm.expectRevert("Transfer to zero address");
        token.transfer(address(0), 100);
    }
}
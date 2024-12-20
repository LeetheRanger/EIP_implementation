// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/MyERC721.sol";

contract MyERC721Test is Test {
    MyERC721 nft;

    address user1 = address(0x1);
    address user2 = address(0x2);

    function setUp() public {
        nft = new MyERC721("MyNFT", "MNFT");
    }

    function testMint() public {
        nft.mint(user1, 1);
        assertEq(nft.balanceOf(user1), 1);
        assertEq(nft.ownerOf(1), user1);
    }

    function testTransfer() public {
        nft.mint(user1, 1);
        vm.prank(user1);
        nft.transferFrom(user1, user2, 1);

        assertEq(nft.ownerOf(1), user2);
        assertEq(nft.balanceOf(user1), 0);
        assertEq(nft.balanceOf(user2), 1);
    }

    function testApproveAndTransferFrom() public {
        nft.mint(user1, 1);

        // Approve user2 to transfer token 1
        vm.prank(user1);
        nft.approve(user2, 1);

        // Check approval
        assertEq(nft.getApproved(1), user2);

        // Transfer token 1 from user1 to user2
        vm.prank(user2);
        nft.transferFrom(user1, user2, 1);

        assertEq(nft.ownerOf(1), user2);
        assertEq(nft.balanceOf(user1), 0);
        assertEq(nft.balanceOf(user2), 1);
    }

    function testSetApprovalForAll() public {
        nft.mint(user1, 1);

        // Approve user2 to manage all tokens of user1
        vm.prank(user1);
        nft.setApprovalForAll(user2, true);

        assertTrue(nft.isApprovedForAll(user1, user2));

        // Transfer token 1 from user1 to user2
        vm.prank(user2);
        nft.transferFrom(user1, user2, 1);

        assertEq(nft.ownerOf(1), user2);
        assertEq(nft.balanceOf(user1), 0);
        assertEq(nft.balanceOf(user2), 1);
    }

    function testTransferFailsIfNotOwnerOrApproved() public {
        nft.mint(user1, 1);

        vm.expectRevert("Not authorized");
        nft.transferFrom(user1, user2, 1);
    }

    function testMintFailsIfAlreadyMinted() public {
        nft.mint(user1, 1);

        vm.expectRevert("Token already minted");
        nft.mint(user2, 1);
    }
}
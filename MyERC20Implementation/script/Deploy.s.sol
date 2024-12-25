   // SPDX-License-Identifier: MIT
   pragma solidity ^0.8.0;

   import "forge-std/Script.sol";
   import "../src/MyERC20.sol";

   contract DeployScript is Script {
       function run() external {
           vm.startBroadcast();
           new MyERC20("HEXTECH", "HEX", 18, 1000000000000000000000000);
           vm.stopBroadcast();
       }
   }
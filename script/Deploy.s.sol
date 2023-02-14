// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/Program.sol";
import "../src/Attestator.sol";
import "../src/Round.sol";
import "../src/Vote.sol";
import "../src/Payout.sol";
contract DeployScript is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        Attestator attestator = new Attestator();
        Program program = new Program(address(0x128), attestator);
        Round round = new Round(address(0x128), attestator);
        Vote vote = new Vote(address(0x128), attestator);
        Payout payout = new Payout(address(0x128), attestator);
        vm.stopBroadcast();

    }
}

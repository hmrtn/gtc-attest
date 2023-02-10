// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "../src/Attestator.sol";

contract AttestatorTest is Test {
    Attestator public attestator;

    address alice_attestor = address(128);
    address bob = address(256);
    address sally = address(512);

    function setUp() public {
        attestator = new Attestator();
                // Give alice and bob some ETH
        vm.deal(alice_attestor, 1 ether);

        vm.label(alice_attestor, "alice_attestor");
        vm.label(bob, "bob");
        vm.label(sally, "sally");
    }

    function testAttest() public {
        attestator.attest(
          { _about: address(this), _key: bytes32("test"), _val: bytes("test") }
        );
    }

}

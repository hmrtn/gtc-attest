// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "../src/Program.sol";
import "../src/Attestator.sol";

contract Program_Init is Test {
  
    Program public program;
    Attestator public attestator;

    address alice = address(128);
    address bob = address(256);
    address sally = address(512);


    function setUp() public {
        // Give alice and bob and sally some ETH
        vm.deal(alice, 1 ether);
        vm.deal(bob, 1 ether);
        vm.deal(sally, 1 ether);

        vm.label(alice, "alice");
        vm.label(bob, "bob");
        vm.label(sally, "sally");
        _initializeContracts();
    }

    function _initializeContracts() internal {
        attestator = new Attestator();
        program = new Program(alice, attestator);
    }


    function attestProgramAdmin(address about) public {
      vm.prank(alice);
      attestator.attest(
        { _about: about, _key: bytes32("program.is_admin"), _val: bytes("true") }
      );
    }
}


contract ProgramTest is Program_Init {

  function testProgramInit() public {
    assertEq(address(program.ATTESTATOR()), address(attestator));
    assertEq(address(program.ATTESTER()), alice);
  }

  function testProgramUpdateMetaPtr_happy() public {
    attestProgramAdmin(bob);
    vm.prank(bob);
    program.updateProgramAttestation(bytes32("program.metaPtr"), "test");
  }

  function testProgramUpdateMetaPtr_sad() public {
    attestProgramAdmin(bob);
    vm.expectRevert("Program::onlyProgramAdmin: NOT_ADMIN");
    vm.prank(sally);
    program.updateProgramAttestation(bytes32("program.metaPtr"), "test");
  }

}

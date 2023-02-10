
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "../src/Round.sol";
import "../src/Program.sol";
import "../src/Attestator.sol";

import "forge-std/console.sol";

contract Round_Init is Test {
  
    Program public program;
    Round public round;
    Attestator public attestator;

    address alice = address(128);
    address bob = address(256);
    address carol = address(512);
    address sally = address(1024);


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
        round = new Round(alice, attestator);
    }

    function attestRoundOperator(address about) public {
      vm.prank(alice);
      attestator.attest(
        { _about: about, _key: bytes32("round.is_operator"), _val: bytes("true") }
      );
    }

}


contract RoundTest is Round_Init {

  function testRoundInit() public {
    assertEq(address(program.ATTESTATOR()), address(attestator));
    assertEq(address(program.ATTESTER()), alice);
    assertEq(address(round.ATTESTATOR()), address(attestator));
    assertEq(address(round.ATTESTER()), alice);
  }

  function testUpdateRoundMetaPtr() public {
    attestRoundOperator(bob);
    vm.prank(bob);
    round.updateRoundAttestation(bytes32("round.metaPtr"), "test-round-meta");
    assertEq(attestator.attestations(address(round), address(round), bytes32("round.metaPtr")), bytes("test-round-meta"));
  }

  function testFailUpdateRoundMetaPtr() public {
    attestRoundOperator(bob);
    vm.prank(bob);
    round.updateRoundAttestation(bytes32("round.metaPtr"), "test-round-meta-1");
    assertEq(attestator.attestations(address(round), address(round), bytes32("round.metaPtr")), bytes("test-round-meta-1"));
    round.updateRoundAttestation(bytes32("round.metaPtr"), "test-round-meta-2");
  }

  function testUpdateProjectsMetaPtr() public {
    attestRoundOperator(bob);
    vm.prank(bob);
    round.updateRoundAttestation(bytes32("round.projects.metaPtr"), "test-round-projects-meta");
    assertEq(attestator.attestations(address(round), address(round), bytes32("round.projects.metaPtr")), bytes("test-round-projects-meta"));
  }

  function testFailUpdateProjectsMetaPtr() public {
    attestRoundOperator(bob);
    vm.prank(bob);
    round.updateRoundAttestation(bytes32("round.projects.metaPtr"), "test-round-projects-meta-1");
    assertEq(attestator.attestations(address(round), address(round), bytes32("round.projects.metaPtr")), bytes("test-round-projects-meta-1"));
    round.updateRoundAttestation(bytes32("round.projects.metaPtr"), "test-round-projects-meta-2");
  }

  function testUpdateApplicationsMetaPtr() public {
    attestRoundOperator(bob);
    vm.prank(bob);
    round.updateRoundAttestation(bytes32("round.applications.metaPtr"), "test-round-applications-meta");
    assertEq(attestator.attestations(address(round), address(round), bytes32("round.applications.metaPtr")), bytes("test-round-applications-meta"));
  }

  function testFailUpdateApplicationsMetaPtr() public {
    attestRoundOperator(bob);
    vm.prank(bob);
    round.updateRoundAttestation(bytes32("round.applications.metaPtr"), "test-round-applications-meta-1");
    assertEq(attestator.attestations(address(round), address(round), bytes32("round.applications.metaPtr")), bytes("test-round-applications-meta-1"));
    round.updateRoundAttestation(bytes32("round.applications.metaPtr"), "test-round-applications-meta-2");
  }

  
  function testSubmitApplication() public {
    vm.prank(carol);
    // enocode the application data
    bytes memory carol_app = abi.encodePacked("carol-test-application-data");
    round.submitApplication(carol_app);
    vm.prank(sally);
    bytes memory sally_app = abi.encodePacked("sally-test-application-data");
    round.submitApplication(sally_app);

    // check that the applications are stored
    assertEq(attestator.attestations(address(round), sally, bytes32("round.application")), sally_app);
    assertEq(attestator.attestations(address(round), carol, bytes32("round.application")), carol_app);
    assertEq(attestator.attestations(address(round), bob, bytes32("round.application")), bytes(""));
  }

  function testVote() public {

    // encode arbitrary vote data from bob for carol and sally
    bytes[] memory votes = new bytes[](2);
    votes[0] = abi.encodePacked(
      bob, 
      sally,
      bytes32("sally-votes")
    );
    
    votes[1] = abi.encodePacked(
      bob,
      carol, 
      bytes32("carol-votes")
    );

    vm.prank(bob);
    round.vote(votes);

    // check that the votes are stored
    assertEq(attestator.attestations(address(round), bob, bytes32("round.vote")), abi.encode(votes));
    bytes[] memory decoded_votes = abi.decode(attestator.attestations(address(round), bob, bytes32("round.vote")), (bytes[]));
    assertEq(decoded_votes[0], votes[0]);
    assertEq(decoded_votes[1], votes[1]);

    // check non votes from random address
    assertEq(attestator.attestations(address(round), address(69), bytes32("round.vote")), bytes(""));
  }


}

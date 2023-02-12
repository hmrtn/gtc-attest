
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "../src/Round.sol";
import "../src/Program.sol";
import "../src/Attestator.sol";
import "../src/Vote.sol";

import "forge-std/console.sol";

contract Round_Init is Test {
  
    Program public program;
    Round public round;
    Vote public vote;
    Attestator public attestator;

    address alice = address(128);
    address bob = address(256);
    address carol = address(512);
    address sally = address(1024);
    address dave = address(2048);


    function setUp() public {
        // Give alice and bob and sally some ETH
        vm.deal(alice, 1 ether);
        vm.deal(bob, 1 ether);
        vm.deal(sally, 1 ether);
        vm.deal(dave, 1 ether);

        vm.label(alice, "alice");
        vm.label(bob, "bob");
        vm.label(sally, "sally");
        vm.label(dave, "dave");
        _initializeContracts();
    }

    function _initializeContracts() internal {
        attestator = new Attestator();
        program = new Program(alice, attestator);
        round = new Round(alice, attestator);
        vote = new Vote(alice, attestator, "vote-contract-1");
    }

    function attestRoundOperator(address about) public {
      vm.prank(alice);
      attestator.attest(
        { _about: about, _key: bytes32("round.is_operator"), _val: bytes("true") }
      );
    }

    function setVotingContract(address votingContract) public {
      round.updateVotingContract(votingContract);
    }

}


contract RoundTest is Round_Init {

  function testRoundInit() public {
    assertEq(address(program.ATTESTATOR()), address(attestator));
    assertEq(address(program.ATTESTER()), alice);
    assertEq(address(round.ATTESTATOR()), address(attestator));
    assertEq(address(round.ATTESTER()), alice);
    assertEq(address(vote.ATTESTATOR()), address(attestator));
    assertEq(address(vote.ATTESTER()), alice);
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

  function testsubmitVote() public {
    attestRoundOperator(bob);
    vm.prank(bob);
    setVotingContract(address(vote)); 

    // create votes data
    bytes[] memory voteData1 = new bytes[](2);
    voteData1[0] = abi.encodePacked(bytes32("test-project-a"), uint256(420));     
    voteData1[1] = abi.encodePacked(bytes32("test-project-b"), uint256(69));

    bytes[] memory voteData2 = new bytes[](2);
    voteData2[0] = abi.encodePacked(bytes32("test-project-a"), uint256(77));
    voteData2[1] = abi.encodePacked(bytes32("test-project-z"), uint256(88));

    vm.prank(dave);
    round.submitVotes(voteData1);

    vm.prank(sally);
    round.submitVotes(voteData2);

    // check that the votes are stored
    assertEq(
      attestator.attestations(address(round), address(vote), bytes32(uint256(uint160(dave)))), 
      abi.encode(voteData1)
    ); 

    assertEq(
      attestator.attestations(address(round), address(vote), bytes32(uint256(uint160(sally)))), 
      abi.encode(voteData2)
    );

    // decode daves votes
    bytes[] memory decodedDaveVotes = abi.decode(
      attestator.attestations(address(round), address(vote), bytes32(uint256(uint160(dave)))), 
      (bytes[])
    );
    (bytes32 daveProjectVote1, uint256 daveProjectWeight1) = abi.decode(decodedDaveVotes[0], (bytes32, uint256));
    (bytes32 daveProjectVote2, uint256 daveProjectWeight2) = abi.decode(decodedDaveVotes[1], (bytes32, uint256));

    assertEq(daveProjectVote1, bytes32("test-project-a"));
    assertEq(daveProjectWeight1, uint256(420));

    assertEq(daveProjectVote2, bytes32("test-project-b"));
    assertEq(daveProjectWeight2, uint256(69));

    // decode sallys votes
    bytes[] memory decodedSallyVotes = abi.decode(
      attestator.attestations(address(round), address(vote), bytes32(uint256(uint160(sally)))), 
      (bytes[])
    );
    (bytes32 sallyProjectVote1, uint256 sallyProjectWeight1) = abi.decode(decodedSallyVotes[0], (bytes32, uint256));
    (bytes32 sallyProjectVote2, uint256 sallyProjectWeight2) = abi.decode(decodedSallyVotes[1], (bytes32, uint256));

    assertEq(sallyProjectVote1, bytes32("test-project-a"));
    assertEq(sallyProjectWeight1, uint256(77));

    assertEq(sallyProjectVote2, bytes32("test-project-z"));
    assertEq(sallyProjectWeight2, uint256(88));

  }


}

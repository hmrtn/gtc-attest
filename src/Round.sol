// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "../src/Attestator.sol";
import {IVote} from "../src/Vote.sol";
import {IPayout} from "../src/Payout.sol";

abstract contract IRound {

  Attestator public ATTESTATOR;
  address public ATTESTER;
  string public NAME;

  constructor(address attester, Attestator attestator, string memory name) {
    ATTESTATOR = attestator;
    NAME = name;
    ATTESTER = attester;
  }

  modifier onlyRoundAdmin() {
    require(ATTESTATOR.attestations(ATTESTER, msg.sender, bytes32("round.is_admin")).length > 0, "Round::onlyRoundAdmin: NOT_ADMIN");
    _;
  }

  function updateRoundAttestation(bytes32 _key, bytes memory _value) public onlyRoundAdmin {
    ATTESTATOR.attest(
      { _about: address(this), _key: _key, _val: _value }
    );
  }
  function submitApplication(bytes memory _data) external virtual;
  function submitPayout(bytes[] calldata _data) external virtual payable;
  function submitVotes(bytes[] calldata _data) external virtual payable;

}

contract Round is IRound {

  constructor(address attester, Attestator attestator, string memory name) IRound(attester, attestator, name) {}

  function updateRoundToken(address _token) external {
    updateRoundAttestation(bytes32("round.contract.token"), abi.encode(_token));
  }

  function updatePayoutContract(address _payout) external {
    updateRoundAttestation(bytes32("round.contract.payout"), abi.encode(_payout));
  }

  function updateVoteContract(address _vote) external {
    updateRoundAttestation(bytes32("round.contract.vote"), abi.encode(_vote));
  }
  
  function submitApplication(bytes memory _application) external override {
    ATTESTATOR.attest(
      { _about: msg.sender, _key: bytes32("round.application"), _val: _application }
    );
  }

  function submitPayout(bytes[] memory _data) external override payable onlyRoundAdmin {
    address payoutContract = abi.decode(
      ATTESTATOR.attestations(ATTESTER, address(this), bytes32("round.contract.payout")), 
      (address)
    );

    if (payoutContract == address(0)) {
      revert("Round::submitPayout: NO_PAYOUT_CONTRACT");
    } 

    IPayout(payoutContract).payout{value: msg.value}(_data);

    ATTESTATOR.attest(
      { _about: address(payoutContract), _key: bytes32("round.paid"), _val: abi.encode(_data) }
    );
  }

  function submitVotes(bytes[] memory _votes) external override payable {
    address votingContract = abi.decode(
      ATTESTATOR.attestations(address(this), address(this), bytes32("round.contract.vote")),
      (address)
    );

    if (votingContract == address(0)) {
      revert("Round::submitVotes: NO_VOTE_CONTRACT");
    }

    IVote(votingContract).vote(_votes);

    ATTESTATOR.attest(
      { _about: votingContract, _key: bytes32(uint256(uint160(msg.sender))), _val: abi.encode(_votes) }
    );

  }

}


// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "../src/Attestator.sol";
import {IVote} from "../src/Vote.sol";
import {IPayout} from "../src/Payout.sol";

contract Round {
  
  Attestator public immutable ATTESTATOR;
  address public immutable ATTESTER;

  constructor(
    address _attester, 
    Attestator _attestator
  ) {
    ATTESTATOR = _attestator; 
    ATTESTER = _attester;
  }

  modifier onlyRoundOperator() {
    require(ATTESTATOR.attestations(ATTESTER, msg.sender, bytes32("round.is_operator")).length > 0, "Round::onlyRoundOperator: NOT_OPERATOR");
    _;
  }

  function updateRoundAttestation(bytes32 _key, bytes memory _value) public onlyRoundOperator {
    ATTESTATOR.attest(
      { _about: address(this), _key: _key, _val: _value }
    );
  }
  
  function updateToken(address _token) public onlyRoundOperator {
    ATTESTATOR.attest(
      { _about: address(this), _key: bytes32("round.token"), _val: abi.encode(_token) }
    );
  }

  function updateVotingContract(address _votingContract) public onlyRoundOperator {
    ATTESTATOR.attest(
      { _about: address(this), _key: bytes32("round.voting_contract"), _val: abi.encode(_votingContract) }
    );
  }

  function updatePayoutContract(address _payoutContract) public onlyRoundOperator {
    ATTESTATOR.attest(
      { _about: address(this), _key: bytes32("round.payout_contract"), _val: abi.encode(_payoutContract) }
    );
  }

  function submitPayout(bytes[] memory _data) public onlyRoundOperator {
    require(
      ATTESTATOR.attestations(ATTESTER, address(this), bytes32("round.payout_contract")).length > 0, 
      "Round::submitPayout: NO_PAYOUT_CONTRACT"
    );

    address payoutContract = abi.decode(
      ATTESTATOR.attestations(ATTESTER, address(this), bytes32("round.payout_contract")), 
      (address)
    );

    IPayout(payoutContract).payout(_data);

    ATTESTATOR.attest(
      { _about: address(payoutContract), _key: bytes32("round.paid"), _val: abi.encode(_data) }
    );
  }

  function submitApplication(bytes memory _application) public {
    ATTESTATOR.attest(
      { _about: msg.sender, _key: bytes32("round.application"), _val: _application }
    );
  }

  function submitVotes(
    bytes[] memory _votes
  ) public payable {
    require(
      ATTESTATOR.attestations(address(this), address(this), bytes32("round.voting_contract")).length > 0,
      "Round::submitVote: VOTING_CONTRACT_NOT_SET"
    );
    // decode packed voting contract address
    address votingContract = abi.decode(
      ATTESTATOR.attestations(address(this), address(this), bytes32("round.voting_contract")),
      (address)
    );

    IVote(votingContract).vote(_votes);

    ATTESTATOR.attest(
      { _about: votingContract, _key: bytes32(uint256(uint160(msg.sender))), _val: abi.encode(_votes) }
    );

  }

  
}

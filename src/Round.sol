// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "../src/Attestator.sol";

contract Round {
  
  Attestator public immutable ATTESTATOR;
  address public immutable ATTESTER;

  address public token;

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

  function updateToken(address _token) public onlyRoundOperator {
    ATTESTATOR.attest(
      { _about: address(this), _key: bytes32("round.token"), _val: abi.encodePacked(_token) }
    );
    token = _token;
  }

  function updateRoundAttestation(bytes32 _key, string memory _value) public onlyRoundOperator {
    ATTESTATOR.attest(
      { _about: address(this), _key: _key, _val: abi.encodePacked(_value) }
    );
  }

  function finalize(bytes[] memory _value) public onlyRoundOperator {
    // finalize logic

    ATTESTATOR.attest(
      { _about: address(this), _key: bytes32("round.finalized"), _val: abi.encode(_value) }
    );
  }

  function payout(bytes[] memory _value) public onlyRoundOperator {
    // Payout logic

    ATTESTATOR.attest(
      { _about: address(this), _key: bytes32("round.paid"), _val: abi.encode(_value) }
    );
  }

  function submitApplication(bytes memory _application) public {
    ATTESTATOR.attest(
      { _about: msg.sender, _key: bytes32("round.application"), _val: _application }
    );
  }

  function vote(bytes[] memory _votes) public payable {
    // Vote logic

    ATTESTATOR.attest(
      { _about: msg.sender, _key: bytes32("round.vote"), _val: abi.encode(_votes) }
    );
  }
  
}

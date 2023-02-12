// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.18;

import "./Attestator.sol";

abstract contract IVote {

  Attestator public ATTESTATOR;
  address public ATTESTER;
  string public NAME;

  constructor(address attester, Attestator attestator, string memory name) {
    ATTESTATOR = attestator;
    NAME = name;
    ATTESTER = attester;
  }
  
  function vote(bytes[] calldata _votes) external virtual;
}

contract Vote is IVote {

  constructor(address attester, Attestator attestator, string memory name) IVote(attester, attestator, name) {}


  function vote(bytes[] memory _votes) external override {

    // Additional Vote logic

  }
}

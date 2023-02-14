// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.18;

import "./Attestator.sol";

abstract contract IVote {

  Attestator public ATTESTATOR;
  address public ATTESTER;

  constructor(address attester, Attestator attestator) {
    ATTESTATOR = attestator;
    ATTESTER = attester;
  }
  
  function vote(bytes[] calldata _votes) external virtual payable;

}

contract Vote is IVote {

  constructor(address attester, Attestator attestator) IVote(attester, attestator) {}


  function vote(bytes[] memory _votes) external override payable {

    // Additional Vote logic

  }
}

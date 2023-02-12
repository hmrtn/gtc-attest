
pragma solidity ^0.8.18;

import "./Attestator.sol";

abstract contract IPayout {

  Attestator public ATTESTATOR;
  address public ATTESTER;
  string public NAME;

  constructor(address attester, Attestator attestator, string memory name) {
    ATTESTATOR = attestator;
    NAME = name;
    ATTESTER = attester;
  }
  
  function payout(bytes[] calldata _data) external virtual payable;

}

contract Payout is IPayout {

  constructor(address attester, Attestator attestator, string memory name) IPayout(attester, attestator, name) {}

  function payout(bytes[] memory _data) external override payable{

    // Additional payout logic

  }
}

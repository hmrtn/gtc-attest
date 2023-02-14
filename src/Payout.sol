
pragma solidity ^0.8.18;

import "./Attestator.sol";

abstract contract IPayout {

  Attestator public ATTESTATOR;
  address public ATTESTER;

  constructor(address attester, Attestator attestator) {
    ATTESTATOR = attestator;
    ATTESTER = attester;
  }
  
  function payout(bytes[] calldata _data) external virtual payable;

}

contract Payout is IPayout {

  constructor(address attester, Attestator attestator) IPayout(attester, attestator) {}

  function payout(bytes[] memory _data) external override payable{

    // Additional payout logic

  }
}

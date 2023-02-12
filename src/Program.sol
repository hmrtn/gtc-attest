pragma solidity 0.8.18;

import { Attestator } from "./Attestator.sol";
import { Round } from "./Round.sol";

abstract contract IProgram {
  Attestator public immutable ATTESTATOR;
  address public immutable ATTESTER;
  constructor(
    address _attester, 
    Attestator _attestator
  ) {
    ATTESTATOR = _attestator; 
    ATTESTER = _attester;
  }

  modifier onlyProgramAdmin() {
    require(ATTESTATOR.attestations(ATTESTER, msg.sender, bytes32("program.is_admin")).length > 0, "Program::onlyProgramAdmin: NOT_ADMIN");
    _;
  }

  function updateProgramAttestation(bytes32 _key, bytes memory _value) public onlyProgramAdmin {
    ATTESTATOR.attest(
      { _about: address(this), _key: _key, _val: _value }
    );
  }

}

contract Program is IProgram {
  constructor(
    address _attester, 
    Attestator _attestator
  ) IProgram(_attester, _attestator) {
    // additional program logic
  }
}

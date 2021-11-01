
//SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.4.25 <=0.8.4;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Commitment.sol";

contract TestCommitment {

    Commitment commitment;

    function testCommitment() public {
        commitment = Commitment(DeployedAddresses.Commitment());
        Assert.notEqual(address(commitment),address(0), "Error : contract not deployed");
    }

}

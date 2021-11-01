// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract Community {

    struct CommittedMember  {
        uint eventsToDo ;

    }

    mapping(address => CommittedMember) public members;

    function becomeCommitted(uint events) public {
       members[msg.sender] = CommittedMember(events);
    }
}



// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract Community {

    struct CommittedMember  {
        uint eventsToCommit;

    }
    bool public isEventActive ;

    mapping(address => CommittedMember) public members;

    function becomeCommitted(uint eventsToCommit) public {
       members[msg.sender] = CommittedMember(eventsToCommit);
    }

    function startEvent() public {
        isEventActive = true;
    }

}



// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract Community {

    struct CommittedMember  {
        uint eventsToCommit;

    }
    bool public isEventActive ;
    address owner;
    mapping(address => CommittedMember) public members;

    constructor(){
        owner = msg.sender;
    }

    function becomeCommitted(uint eventsToCommit) public {
       members[msg.sender] = CommittedMember(eventsToCommit);
    }

    function startEvent() public {
        require(msg.sender == owner,"Only owner can start an event");
        require(isEventActive == false, "An existing event is already active, you must close it before starting a new one");
        isEventActive = true;
    }

}



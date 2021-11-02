// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

contract Community {
    address owner;
    struct CommittedMember  {
        uint eventsToCommit;
    }
    mapping(address => CommittedMember) public members;

    struct Event {
        bool active;
        uint participants;
        mapping(address => uint) feedbacks;
    }
    uint eventId;
    mapping(uint => Event) public events;

    constructor(){
        owner = msg.sender;
    }

    function becomeCommitted(uint eventsToCommit) public {
       members[msg.sender] = CommittedMember(eventsToCommit);
    }

    function startEvent() public {
        require(msg.sender == owner,"Only owner can start an event");
        require(events[eventId].active == false, "An existing event is already active, you must close it before starting a new one");
        Event storage newEvent = events[eventId];
        newEvent.active = true;
    }

    function closeEvent() public {
        require(msg.sender == owner,"Only owner can stop an event");
        require(events[eventId].active == true, "An existing event must be active before stopping it");
        events[eventId].active = false;
        eventId++;
    }

    function setCurrentEventFeedback(uint feedback) public {
        events[eventId].feedbacks[msg.sender] = feedback;
        events[eventId].participants++;
    }

    function getCurrentEventFeedback() public view returns (uint){
        return events[eventId].feedbacks[msg.sender];
    }

}



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
        uint expectedParticipants;
        uint rewards;
        address[] voters;
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

    function startEvent(uint expectedPeople) public {
        require(msg.sender == owner,"Only owner can start an event");
        require(events[eventId].active == false, "An existing event is already active, you must close it before starting a new one");
        Event storage newEvent = events[eventId];
        newEvent.expectedParticipants = expectedPeople;
        newEvent.active = true;
    }

    function closeEvent() public {
        require(msg.sender == owner,"Only owner can stop an event");
        require(events[eventId].active == true, "An existing event must be active before stopping it");
        events[eventId].active = false;
        events[eventId].rewards = makeRewardCalculus();
        updateMembersCommitment();
        eventId++;
    }

    function setCurrentEventFeedback(uint feedback) public {
        require(events[eventId].active == true,"To give your feedback, an event must be active");
        events[eventId].feedbacks[msg.sender] = feedback;
        events[eventId].voters.push(msg.sender);
        events[eventId].participants++;
    }

    function getCurrentEventFeedback() public view returns (uint){
        return events[eventId].feedbacks[msg.sender];
    }

    function updateMembersCommitment() private {
        for(uint i=0;i<events[eventId].participants;i++){
            if(members[events[eventId].voters[i]].eventsToCommit > 1 ){
                members[events[eventId].voters[i]].eventsToCommit--;
            }
        }
    }

    function makeRewardCalculus() private view returns (uint)  {
        uint rewardFromParticipants = events[eventId].participants / events[eventId].expectedParticipants;
        return (rewardFromParticipants + rewardFromFeedback()) * 10000;
    }

    function rewardFromFeedback() private view returns (uint) {
       return events[eventId].participants > 0 ? meanFeedback() : 0;
    }

    function meanFeedback() private view returns (uint){
        uint totalFeedback;
        for(uint i=0;i<events[eventId].participants;i++){
            totalFeedback += events[eventId].feedbacks[events[eventId].voters[i]];
        }
        return totalFeedback / events[eventId].participants ;
    }

}



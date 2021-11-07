// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

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
    ERC20 token;

    constructor(address communityToken){
        token = ERC20(address(communityToken));
        owner = msg.sender;
    }

    function becomeCommitted(uint eventsToCommit) external {
       members[msg.sender] = CommittedMember(eventsToCommit);
    }

    function startEvent(uint expectedPeople) external {
        require(msg.sender == owner,"Only owner can start an event");
        require(events[eventId].active == false, "An existing event is already active, you must close it before starting a new one");
        Event storage newEvent = events[eventId];
        newEvent.expectedParticipants = expectedPeople;
        newEvent.active = true;
    }

    function closeEvent() external {
        require(msg.sender == owner,"Only owner can stop an event");
        require(events[eventId].active == true, "An existing event must be active before stopping it");
        events[eventId].active = false;
        token.transferFrom(msg.sender, address(this), events[eventId].rewards);
        eventId++;
    }

    function setCurrentEventFeedback(uint feedback) external {
        require(events[eventId].active == true,"To give your feedback, an event must be active");
        if (events[eventId].feedbacks[msg.sender] == 0){
            events[eventId].participants++;
            events[eventId].voters.push(msg.sender);
            updateMembersCommitment();
        }
        events[eventId].feedbacks[msg.sender] = feedback;
        events[eventId].rewards = assignReward();

    }

    function getCurrentEventFeedback() public view returns (uint){
        return events[eventId].feedbacks[msg.sender];
    }


    function updateMembersCommitment() private {
            if(members[msg.sender].eventsToCommit > 1 ){
                members[msg.sender].eventsToCommit--;
        }
    }

    function assignReward() private view returns (uint)  {
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



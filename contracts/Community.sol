// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Community {
    address owner;
    struct CommittedMember  {
        uint eventsToCommit;
        uint currentEventRewards;
        uint lastEventRewards;
    }
    mapping(address => CommittedMember) public members;

    struct Event {
        bool open;
        uint expectedParticipants;
        uint rewards;
        address[] committedParticipants;
        address[] standardParticipants;
        mapping(address => uint) feedbacks;
    }
    uint public eventId ;
    mapping(uint => Event) public events;
    ERC20 token;

    constructor(address communityToken){
        token = ERC20(address(communityToken));
        owner = msg.sender;
    }

    function becomeCommitted(uint eventsToCommit) external {
        require(eventsToCommit > 0,"member must commit to come at least 1 event");
        require(eventsToCommit >= members[msg.sender].eventsToCommit,"member must commit come at least its today commitment");
        members[msg.sender] = CommittedMember(eventsToCommit,0,0);
    }

    function startEvent(uint expectedPeople) external {
        require(msg.sender == owner,"Only owner can start an event");
        require(events[eventId].open == false, "An existing event is already active, you must close it before starting a new one");
        initializeEvent(expectedPeople);
    }

    function updateEvent(uint feedback) external {
        require(events[eventId].open == true,"To give your feedback, an event must be active");
        require(feedback > 0, "feedback must be at least equal to 1");

        if (hasNotGivenHisFeedbackYet()){ addMemberAsEventParticipant();}
        if (isCommittedMember() && hasNotGivenHisFeedbackYet()){ decreaseCommittedMemberCommitment();}

        events[eventId].feedbacks[msg.sender] = feedback;
        events[eventId].rewards = updateEventReward();
        updateCommittedParticipantReward();

    }

    function closeEvent() external {
        require(msg.sender == owner,"Only owner can stop an event");
        require(events[eventId].open == true, "An existing event must be active before stopping it");
        token.transferFrom(msg.sender, address(this), events[eventId].rewards);
        for (uint i=0;i< eventCommittedParticipantNumber();i++){
            address committedParticipant = events[eventId].committedParticipants[i];
            memberHasFinishedHisCommitment(committedParticipant) ? transformCommittedMemberToStandardMember(committedParticipant) : keepCommittedMemberAsCommittedMember(committedParticipant);
        }
        moveToNextEvent();
    }


    function updateCommittedParticipantReward() private {
        uint eventRewards = events[eventId].rewards / eventCommittedParticipantNumber();
        for (uint i=0;i< eventCommittedParticipantNumber();i++){
            members[events[eventId].committedParticipants[i]].currentEventRewards = eventRewards;
        }
    }

    function updateEventReward() private view returns (uint)  {
        uint rewardFromParticipants = eventParticipantNumber() / events[eventId].expectedParticipants;
        return (rewardFromParticipants + rewardFromFeedback()) * 10000;
    }

    function keepCommittedMemberAsCommittedMember(address member) private {
        members[member].lastEventRewards += members[member].currentEventRewards;
        members[member].currentEventRewards = 0;
    }

    function transformCommittedMemberToStandardMember(address member) private {
        transferTotalRewardToMember(member);
        delete members[member];
    }
    function transferTotalRewardToMember(address member) private {
        uint totalReward = members[member].currentEventRewards + members[member].lastEventRewards;
        token.transfer(member,totalReward);
    }

    function decreaseCommittedMemberCommitment() private {
        members[msg.sender].eventsToCommit--;
    }

    function moveToNextEvent() private {
        events[eventId].open = false;
        eventId++;
    }

    function addMemberAsEventParticipant() private {
        isCommittedMember() ? events[eventId].committedParticipants.push(msg.sender) : events[eventId].standardParticipants.push(msg.sender);
    }

    function eventParticipantNumber() private view returns (uint){
        return events[eventId].standardParticipants.length + eventCommittedParticipantNumber();
    }

    function eventCommittedParticipantNumber() private view returns (uint) {
        return events[eventId].committedParticipants.length;
    }

    function rewardFromFeedback() private view returns (uint) {
       return eventParticipantNumber() > 0 ? meanFeedback() : 0;
    }

    function meanFeedback() private view returns (uint){
        uint totalFeedback;
        totalFeedback += sumFeedbacksFrom(events[eventId].standardParticipants);
        totalFeedback += sumFeedbacksFrom(events[eventId].committedParticipants);
        return totalFeedback / eventParticipantNumber() ;
    }

    function sumFeedbacksFrom(address[] memory people) private view returns(uint) {
        uint totalFeedback = 0;
        for(uint i=0;i< people.length ;i++){
            totalFeedback += events[eventId].feedbacks[people[i]];
        }
        return totalFeedback;
    }
    function memberHasFinishedHisCommitment(address committedMember) private view returns (bool) {
        return members[committedMember].eventsToCommit == 0;
    }

    function isCommittedMember() private view returns (bool){
        return members[msg.sender].eventsToCommit > 0;
    }

    function hasNotGivenHisFeedbackYet() private view returns (bool){
        return events[eventId].feedbacks[msg.sender] == 0;
    }

    function initializeEvent(uint expectedPeople) private {
        Event storage newEvent = events[eventId];
        newEvent.expectedParticipants = expectedPeople;
        newEvent.open = true;
    }
}



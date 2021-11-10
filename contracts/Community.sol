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
    mapping(address => CommittedMember) public committedMembers;

    struct Event {
        bool open;
        uint expectedParticipants;
        uint rewards;
        address[] committedParticipants;
        address[] nonCommittedParticipants;
        mapping(address => uint) feedbacks;
    }
    uint public currentEvent;
    mapping(uint => Event) public events;
    ERC20 public token;

    constructor(address communityToken){
        token = ERC20(address(communityToken));
        owner = msg.sender;
    }

    function swapToCommittedMember(uint eventsToCommit) external {
        require(eventsToCommit > 0,"member must commit to come at least 1 event");
        require(eventsToCommit >= committedMembers[msg.sender].eventsToCommit,"member must commit come at least its today commitment");
        committedMembers[msg.sender] = CommittedMember(eventsToCommit,0,0);
    }

    function startEvent(uint expectedPeople) external {
        require(msg.sender == owner,"Only owner can start an event");
        require(events[currentEvent].open == false, "An existing event is already active, you must close it before starting a new one");
        initializeEvent(expectedPeople);
    }

    function updateEvent(uint feedback) external {
        require(events[currentEvent].open == true,"To give your feedback, an event must be active");
        require(feedback > 0, "feedback must be at least equal to 1");

        if (hasNotGivenHisFeedbackYet()){ addMemberAsEventParticipant();}
        if (isCommittedMember() && hasNotGivenHisFeedbackYet()){ committedMembers[msg.sender].eventsToCommit--;}

        events[currentEvent].feedbacks[msg.sender] = feedback;
        events[currentEvent].rewards = updateEventReward();
        updateCommittedParticipantReward();

    }

    function closeEvent() external {
        require(msg.sender == owner,"Only owner can stop an event");
        require(events[currentEvent].open == true, "An existing event must be active before stopping it");
        token.transferFrom(msg.sender, address(this), events[currentEvent].rewards);
        for (uint i=0;i< eventCommittedParticipantNumber();i++){
            address committedParticipant = events[currentEvent].committedParticipants[i];
            memberHasFinishedHisCommitment(committedParticipant) ? swapToNonCommittedMember(committedParticipant) : keepCommittedMemberAsCommittedMember(committedParticipant);
        }
        moveToNextEvent();
    }


    function updateCommittedParticipantReward() private {
        uint eventRewards = events[currentEvent].rewards / eventCommittedParticipantNumber();
        for (uint i=0;i< eventCommittedParticipantNumber();i++){
            committedMembers[events[currentEvent].committedParticipants[i]].currentEventRewards = eventRewards;
        }
    }

    function updateEventReward() private view returns (uint)  {
        uint rewardFromParticipants = eventParticipantNumber() / events[currentEvent].expectedParticipants;
        return (rewardFromParticipants + rewardFromFeedback()) * 10000;
    }

    function keepCommittedMemberAsCommittedMember(address member) private {
        committedMembers[member].lastEventRewards += committedMembers[member].currentEventRewards;
        committedMembers[member].currentEventRewards = 0;
    }

    function swapToNonCommittedMember(address member) private {
        transferTotalRewardToMember(member);
        delete committedMembers[member];
    }
    function transferTotalRewardToMember(address member) private {
        uint totalReward = committedMembers[member].currentEventRewards + committedMembers[member].lastEventRewards;
        token.transfer(member,totalReward);
    }

    function decreaseCommittedMemberCommitment() private {
        committedMembers[msg.sender].eventsToCommit--;
    }

    function moveToNextEvent() private {
        events[currentEvent].open = false;
        currentEvent++;
    }

    function addMemberAsEventParticipant() private {
        isCommittedMember() ? events[currentEvent].committedParticipants.push(msg.sender) : events[currentEvent].nonCommittedParticipants.push(msg.sender);
    }

    function eventParticipantNumber() private view returns (uint){
        return events[currentEvent].nonCommittedParticipants.length + eventCommittedParticipantNumber();
    }

    function eventCommittedParticipantNumber() private view returns (uint) {
        return events[currentEvent].committedParticipants.length;
    }

    function rewardFromFeedback() private view returns (uint) {
       return eventParticipantNumber() > 0 ? meanFeedback() : 0;
    }

    function meanFeedback() private view returns (uint){
        uint totalFeedback;
        totalFeedback += sumFeedbacksFrom(events[currentEvent].nonCommittedParticipants);
        totalFeedback += sumFeedbacksFrom(events[currentEvent].committedParticipants);
        return totalFeedback / eventParticipantNumber() ;
    }

    function sumFeedbacksFrom(address[] memory people) private view returns(uint) {
        uint totalFeedback = 0;
        for(uint i=0;i< people.length ;i++){
            totalFeedback += events[currentEvent].feedbacks[people[i]];
        }
        return totalFeedback;
    }
    function memberHasFinishedHisCommitment(address committedMember) private view returns (bool) {
        return committedMembers[committedMember].eventsToCommit == 0;
    }

    function isCommittedMember() private view returns (bool){
        return committedMembers[msg.sender].eventsToCommit > 0;
    }

    function hasNotGivenHisFeedbackYet() private view returns (bool){
        return events[currentEvent].feedbacks[msg.sender] == 0;
    }

    function initializeEvent(uint expectedPeople) private {
        Event storage newEvent = events[currentEvent];
        newEvent.expectedParticipants = expectedPeople;
        newEvent.open = true;
    }
}



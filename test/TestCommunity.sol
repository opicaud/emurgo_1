
//SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.4.25 <=0.8.4;

import "truffle/Assert.sol";
import "../contracts/Community.sol";
import "../contracts/CommunityToken.sol";

contract TestCommunity {

    Community community;
    ERC20 token;
    function beforeEach() public {
        token = new CommunityToken();
        community = new Community(address(token));
        Assert.notEqual(address(community),address(0), "Error : contract not deployed");
        token.increaseAllowance(address(community), 100000);
        Assert.equal(token.balanceOf(address(community)),0, "Error : balance of contract should be 0");
        community.startEvent(10);
        (,,uint expectedParticipants,) = community.events(0);
        Assert.equal(expectedParticipants,10, "Error : incorrect number of expected participants");

    }

    function test_member_should_become_a_committed_member_for_a_number_of_events() public {
        uint events = 5;
        community.becomeCommitted(events);
        uint eventCommitted = community.members(address (this));
        Assert.equal(eventCommitted, events, "Error : number of committed event not correct");
    }

    function test_owner_should_start_a_community_event_() public {
        (bool active,,,) = community.events(0);
        Assert.equal(active, true, "Error : after starting an event, event must be active");
    }

    function test_owner_should_close_a_community_event() public {
        community.closeEvent();
        (bool active,,,) = community.events(0);
        Assert.equal(active, false, "Error : after stoping an event, event must be inactive");
    }

    function test_members_should_give_their_feedback_only_when_event_is_active() public {
        community.setCurrentEventFeedback(5);
        uint eventFeedback = community.getCurrentEventFeedback();
        Assert.equal(eventFeedback, 5,"Error : incorrect feedback");
    }

    function test_should_know_the_number_of_participants() public {
        community.setCurrentEventFeedback(5);
        community.closeEvent();
        (,uint participants,,) = community.events(0);
        Assert.equal(participants, 1,"Error : incorrect number of participants");
    }

    function test_commited_members_who_has_participated_has_one_less_event_to_commit() public {
        community.becomeCommitted(2);
        community.setCurrentEventFeedback(5);
        community.closeEvent();
        uint eventCommitted = community.members(address (this));
        Assert.equal(eventCommitted, 1,"Error : incorrect number events to commit");
    }

    function test_make_reward_calculus() public {
        community.setCurrentEventFeedback(5);
        community.closeEvent();
        (,,,uint reward) = community.events(0);
        Assert.equal(reward, 50000,"Error : incorrect number events to commit");
        Assert.equal(token.balanceOf(address(community)), 50000, "");
    }


}


//SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.4.25 <=0.8.4;

import "truffle/Assert.sol";
import "../contracts/Community.sol";

contract TestCommunity {

    Community community;

    function beforeEach() public {
        community = new Community();
        Assert.notEqual(address(community),address(0), "Error : contract not deployed");
    }

    function test_member_should_become_a_committed_member_for_a_number_of_events() public {
        uint events = 5;
        community.becomeCommitted(events);
        uint eventCommitted = community.members(address (this));
        Assert.equal(eventCommitted, events, "Error : number of committed event not correct");
    }

    function test_owner_should_start_a_community_event_() public {
        community.startEvent();
        (bool active,) = community.events(0);
        Assert.equal(active, true, "Error : after starting an event, event must be active");
    }

    function test_owner_should_stop_a_community_event_() public {
        community.startEvent();
        community.closeEvent();
        (bool active,) = community.events(0);
        Assert.equal(active, false, "Error : after stoping an event, event must be inactive");
    }

    function test_members_should_give_their_feedback() public {
        community.setCurrentEventFeedback(5);
        uint eventFeedback = community.getCurrentEventFeedback();
        Assert.equal(eventFeedback, 5,"Error : incorrect feedback");
    }

    function test_should_know_the_number_of_participants() public {
        community.startEvent();
        community.setCurrentEventFeedback(5);
        community.closeEvent();
        (,uint participants) = community.events(0);
        Assert.equal(participants, 1,"Error : incorrect number of participants");


    }


}

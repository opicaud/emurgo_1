
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

        community.becomeCommitted(2);
        community.startEvent(10);
        community.updateEvent(5);
    }

    function test_committed_members_who_has_participated_has_one_less_event_to_commit() public {
        uint eventCommitted = community.members(address (this));
        Assert.equal(eventCommitted, 1,"Error : incorrect number events to commit");
    }

    function test_event_should_have_a_number_of_expected_participants() public{
        (,,uint expectedParticipants,) = community.events(0);
        Assert.equal(expectedParticipants,10, "Error : incorrect number of expected participants");
    }

    function test_event_should_be_opened() public {
        (bool opened,,,) = community.events(0);
        Assert.equal(opened, true, "Error : after starting an event, event must be opened");
    }

    function test_event_should_have_the_number_of_participants() public {
        (,uint participants,,) = community.events(0);
        Assert.equal(participants, 1,"Error : incorrect number of participants");
    }

    function test_event_should_have_a_reward_calculus() public {
        (,,,uint reward) = community.events(0);
        Assert.equal(reward, 50000,"Error : incorrect rewards");
    }

    function test_event_should_be_closed() public {
        community.closeEvent();
        Assert.equal(token.balanceOf(address(community)), 50000, "balance of community is not correct");
        Assert.equal(community.eventId(), 1, "id of next event is not correct");

    }
}


//SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.4.25 <=0.8.4;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Community.sol";

contract TestCommunity {

    Community community;

    function beforeEach() public {
        community = Community(DeployedAddresses.Community());
        Assert.notEqual(address(community),address(0), "Error : contract not deployed");
    }

    function test_member_should_become_a_committed_member_for_a_number_of_events() public {
        uint events = 5;
        community.becomeCommitted(events);
        Assert.equal(community.members(address(this)), events, "Error : number of committed event not correct");
    }

    function test_owner_should_start_a_community_event_() public {
        Assert.equal(community.isEventActive(), false, "Error : before starting an event, event must be inactive");
        community.startEvent();
        Assert.equal(community.isEventActive(), true, "Error : after starting an event, event must be active");
    }

}

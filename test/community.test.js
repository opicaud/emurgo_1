const Community = artifacts.require("Community.sol");
const CommunityToken = artifacts.require("CommunityToken.sol")
const truffleAssert = require('truffle-assertions');



contract('Community', (accounts) => {
    async function fetchEvent(id) {
        const event = await community.events(id);

        return {
            active: event['0'],
            participants: event['1'].toNumber(),
            expectedParticipants: event['2'].toNumber(),
            reward: event['3'].toNumber()
        }

    }

    let community, communityToken;
    const totalSupply = 1000000;
    const members = [
        {name: "Alice", account: accounts[1], committedEvents: 6, eventFeedback: 5},
        {name: "Bob", account: accounts[2], committedEvents: 5, eventFeedback:3},
        {name: "Charles", account: accounts[3], committedEvents: 3, eventFeedback:2}]
    const expectedPeople = 10;

    describe('Given a Community', async () => {
        community = await Community.deployed()
        communityToken = await CommunityToken.deployed();
        describe('Given a tokeneconomy of the community', async () => {
            it('Its token has a supply of ' + totalSupply, async() => {
                const totalSupplyExpected = await communityToken.totalSupply();
                assert.equal(totalSupplyExpected.toNumber(), totalSupply);
            })
        })
        describe('Given some community member', async () => {
            members.forEach(member => {
                describe('When '+ member.name + ' commit to come to '+member.committedEvents + ' events', async () => {
                    it('Then ' + member.name + '\'s commitment is contracted'  , async () => {
                        await community.becomeCommitted(member.committedEvents, {from: member.account})
                        const choice= await community.members(member.account)
                        assert.equal(choice.toNumber(), member.committedEvents)
                    })
                })
                describe('When '+ member.name + ' wants to start an event', async () => {
                    it('Then ' + member.name + ' is disallowed to do it, she is not an owner', async () => {
                        assert.equal((await fetchEvent(0)).active, false)
                        await truffleAssert.reverts(community.startEvent(expectedPeople, {from: member.account}),
                            "Only owner can start an event")
                    })
                })
                describe('When '+ member.name + ' wants to stop an event', async () => {
                    it('Then ' + member.name + ' is disallowed to do it, she is not an owner', async () => {
                        assert.equal((await fetchEvent(0)).active, false)
                        await truffleAssert.reverts(community.closeEvent( {from: member.account}),
                            "Only owner can stop an event")
                    })
                })
            })
        })
        describe('Given the owner of the community', async () => {
            describe('When he decides to start an event with 10 expected people', async () => {
                it('Then the start of the event is contracted', async () => {
                    assert.equal((await fetchEvent(0)).active, false)
                    await community.startEvent(expectedPeople);
                    assert.equal((await fetchEvent(0)).active, true)
                    assert.equal((await fetchEvent(0)).expectedParticipants, expectedPeople)


                })
                it('And only one event can be started at same time', async () => {
                    await truffleAssert.reverts(community.startEvent(expectedPeople),
                        "An existing event is already active, you must close it before starting a new one")
                })
                members.forEach(member => {
                    it('And ' + member.name + ' can give their feedback about the event' , async () => {
                        await community.setCurrentEventFeedback(member.eventFeedback, {from: member.account});
                        const feedback = await community.getCurrentEventFeedback({from: member.account})
                        assert.equal(feedback, member.eventFeedback)
                    })
                })
            })
            describe('When he decides to close the event', async () =>{
                it('Then the close of the event is contracted', async () => {
                    await community.closeEvent();
                    assert.equal((await fetchEvent(0)).active, false)
                    assert.equal((await fetchEvent(1)).active, false)
                })
                it('Then ' + members.length + ' has participated to the event', async () => {
                    assert.equal((await fetchEvent(0)).participants, 3)
                })
                it('Then a number of AM token is distributed to the event', async () => {
                    const event = await fetchEvent(0)
                    let totalFeedback = 0
                    members.forEach(member => totalFeedback+=member.eventFeedback)
                    const rewardExpected = (Math.trunc(event.participants / event.expectedParticipants) + Math.trunc(totalFeedback / event.participants))*10000
                    assert.equal(event.reward, rewardExpected)
                })
                members.forEach(member => {
                    it('Then ' + member.name + ' has ' + eval(member.committedEvents - 1 )+ ' events to commit', async () => {
                        const choice= await community.members(member.account)
                        assert.equal(choice.toNumber(), member.committedEvents - 1)
                    })
                    it('Then ' + member.name + ' can not give their feedback to any events', async () => {
                        await truffleAssert.reverts(
                            community.setCurrentEventFeedback(member.eventFeedback, {from: member.account}),
                            "To give your feedback, an event must be active");

                    })
                    xit('Then ' + member.name + ' receive a number of AM token', async () => {

                    })
                })
            })
        })
    });
});

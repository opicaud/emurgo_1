const Community = artifacts.require("Community.sol");
const truffleAssert = require('truffle-assertions');

contract('Community', (accounts) => {
    let community;
    const members = [
        {name: "Alice", account: accounts[1], committedEvents: 6, eventFeedback: 5},
        {name: "Bob", account: accounts[2], committedEvents: 5, eventFeedback:3},
        {name: "Charles", account: accounts[3], committedEvents: 3, eventFeedback:2}]
    describe('Given a Community', async () => {
        community = await Community.deployed()
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
                        assert.equal(await community.events(0), false)
                        await truffleAssert.reverts(community.startEvent( {from: member.account}),
                            "Only owner can start an event")
                    })
                })
                describe('When '+ member.name + ' wants to stop an event', async () => {
                    it('Then ' + member.name + ' is disallowed to do it, she is not an owner', async () => {
                        assert.equal(await community.events(0), false)
                        await truffleAssert.reverts(community.closeEvent( {from: member.account}),
                            "Only owner can stop an event")
                    })
                })
            })
        })
        describe('Given the owner of the community', async () => {
            describe('When he decides to start an event', async () => {
                it('Then the start of the event is contracted', async () => {
                    assert.equal(await community.events(0), false)
                    await community.startEvent();
                    assert.equal(await community.events(0), true)
                })
                it('And only one event can be started at same time', async () => {
                    await truffleAssert.reverts(community.startEvent(),
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
                xit('Then the stop of the event is contracted', async () => {
                    await community.closeEvent();
                    assert.equal(await community.events(0), false)
                    assert.equal(await community.events(1), false)
                })
                xit('Then ' + members.length + ' has participated to the event', async () => {

                })
                xit('Then a number of AM token is distributed to the event', async () => {

                })
                members.forEach(member => {
                    xit('Then ' + member.name + ' has ' + eval(member.committedEvents - 1 )+ ' events to commit', async () => {

                    })
                    xit('Then ' + member.name + ' can not give their feedback to any events', async () => {

                    })
                    xit('Then ' + member.name + ' receive a number of AM token', async () => {

                    })
                })
            })
        })
    });
});

const Community = artifacts.require("Community.sol");
const truffleAssert = require('truffle-assertions');

contract('Community', (accounts) => {
    let community;
    const members = [
        {name: "Alice", account: accounts[1], committedEvents: 6},
        {name: "Bob", account: accounts[2], committedEvents: 5},
        {name: "Charles", account: accounts[3], committedEvents: 3}]
    describe('Given a Community', async () => {
        community = await Community.deployed()
        describe('Given some community member', async () => {
            members.forEach(member => {
                describe('When '+ member.name + ' commit to come to '+member.committedEvents + ' events', async () => {
                    it('Then ' + member.name + '\'s commitment is contracted'  , async () => {
                        await community.becomeCommitted(member.committedEvents, {from: member.account})
                        const choice = await community.members(member.account)
                        assert.equal(choice.toNumber(), member.committedEvents)
                    })
                })
                describe('When '+ member.name + ' wants to start an event', async () => {
                    it('Then ' + member.name + ' is disallowed to do it', async () => {
                        assert.equal(await community.isEventActive(), false)
                        await truffleAssert.reverts(community.startEvent( {from: member.account}),
                            "Only owner can start an event")
                    })
                })
            })
        })
        describe('Given the owner of the community', async () => {
            describe('When he wants to start an event', async () => {
                it('Then the start of the event is contracted', async () => {
                    assert.equal(await community.isEventActive(), false)
                    await community.startEvent();
                    assert.equal(await community.isEventActive(), true)
                })
                it('And only one event can be started at same time', async () => {
                    await truffleAssert.reverts(community.startEvent(),
                        "An existing event is already active, you must close it before starting a new one")
                })
            })
        })
    });
});

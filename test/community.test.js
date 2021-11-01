const Community = artifacts.require("Community.sol");

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

            })

        })
    });
});

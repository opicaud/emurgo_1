const Community = artifacts.require("Community.sol");
const CommunityToken = artifacts.require("CommunityToken.sol")
const truffleAssert = require('truffle-assertions');

contract('Community', (accounts) => {
    let communityContract, communityToken;
    async function fetchMember(address) {
        const event = await communityContract.members(address)

        return {
            commitment: event['0'].toNumber(),
            currentEventRewards: event['1'].toNumber(),
            lastEventRewards: event['2'].toNumber()

        }

    }

    async function fetchEvent(id) {
        const event = await communityContract.events(id);

        return {
            active: event['0'],
            participants: event['1'].toNumber(),
            expectedParticipants: event['2'].toNumber(),
            reward: event['3'].toNumber()
        }

    }
    const community = {
        events: [{
            before: {
                new_committed_members: [{
                        account: accounts[1], commitment: 3
                    }, {
                        account: accounts[2], commitment: 2
                 }]
            },
            name: 'Event 1', participantExpected: 5,
            during: {
                feedbacks: [{
                    account: accounts[1], feedback: 1
                }, {
                    account: accounts[2], feedback: 4
                }, {
                    account: accounts[3], feedback: 3
                }, {
                    account: accounts[4], feedback: 2
                }]
            },
            after: {
                members: [{
                    account: accounts[1], committed: 'yes', commitment: 2, balance: 0, potential_rewards: 10000
                }, {
                    account: accounts[2], committed: 'yes', commitment: 1, balance: 0, potential_rewards: 10000
                }, {
                    account: accounts[3] ,committed: 'no', balance: 0, potential_rewards: 0,
                }, {
                    account: accounts[4] ,committed: 'no', balance: 0, potential_rewards: 0,
                }],
                community:{
                    balance: 20000,
                },
                rewards: 20000
            }
        },{
            before: {
                new_committed_members:[{
                        account: accounts[3] , commitment: 5,
                    }
                ]},
            name: 'Event 2', participantExpected: 3,
            during: {
                feedbacks: [{
                    account: accounts[2], feedback: 5
                }, {
                    account: accounts[3], feedback: 4
                }, {
                    account: accounts[4], feedback: 4
                }, {
                    account: accounts[5], feedback: 4
                }, {
                    account: accounts[6], feedback: 5
                }, {
                    account: accounts[7], feedback: 5
                }]
            },
            after: {
                members: [{
                    account: accounts[1], committed: 'yes', commitment: 2, balance: 0, potential_rewards: 10000
                }, {
                    account: accounts[2], committed: 'yes', commitment: 0, balance: 40000, potential_rewards: 0
                }, {
                    account: accounts[3] ,committed: 'yes', commitment: 4, balance: 0, potential_rewards: 30000
                },{
                    account: accounts[4] ,committed: 'no', balance: 0, potential_rewards: 0
                },{
                    account: accounts[4] ,committed: 'no', balance: 0, potential_rewards: 0
                },{
                    account: accounts[5] ,committed: 'no', balance: 0, potential_rewards: 0
                }, {
                    account: accounts[6] ,committed: 'no', balance: 0, potential_rewards: 0
                }, {
                    account: accounts[7] ,committed: 'no', balance: 0, potential_rewards: 0
                }

                ],
                community:{
                    balance: 40000,
                },
                rewards: 60000
            }
        }]
    }

    describe('Given a Community', async () => {
        communityContract = await Community.deployed()
        communityToken = await CommunityToken.deployed();
        await communityToken.increaseAllowance(communityContract.address, 1000000);

        community.events.forEach(event => {
            event.before.new_committed_members.forEach(member => {
                describe('When ' + member.account + ' is committed of '+ member.commitment + ' events', async () => {
                    it('Then ' + member.account + '\'s commitment is contracted', async() => {
                        await communityContract.becomeCommitted(member.commitment, {from: member.account})
                        const committedMember= await fetchMember(member.account)
                        assert.equal(committedMember.commitment, member.commitment)
                    })
                });
            })
            describe('When the community is organising the event ' + event.name, async () => {
                it('Then the start of the event is contracted with ' + event.participantExpected + ' expected participants', async () => {
                    await communityContract.startEvent(event.participantExpected);
                    const id = await communityContract.eventId()
                    assert.equal((await fetchEvent(id.toNumber())).expectedParticipants, event.participantExpected)
                })
            });
            event.during.feedbacks.forEach(feedback => {
                describe('During the event, when member give their feedback', async () => {
                    it('Then their feedback are contracted', async () => {
                        await communityContract.updateEvent(feedback.feedback, {from: feedback.account});
                    })
                });
            })
            describe('After closing the event', async () => {
                it('Then a reward is calculated for the event', async () => {
                    const id = await communityContract.eventId()
                    await communityContract.closeEvent();
                    const closedEvent = await fetchEvent(id.toNumber());
                    assert.equal(closedEvent.reward, event.after.rewards)
                })
                event.after.members.filter( member => member.committed === 'yes' && member.commitment > 0).forEach(member => {
                    it('Then committed member ' + member.account +' commitment is updated', async () => {
                        const committedMember= await fetchMember(member.account)
                        assert.equal(committedMember.commitment, member.commitment)
                    })
                    it('Then committed member ' + member.account +' have a potential reward of '+ member.potential_rewards , async () => {
                        const committedMember= await fetchMember(member.account)
                        assert.equal(committedMember.lastEventRewards, member.potential_rewards)
                    })
                    it('Then committed member ' + member.account +' have a balance of ' + member.balance, async () => {
                        const balance= await communityToken.balanceOf(member.account)
                        assert.equal(balance.toNumber(), member.balance)
                    })
                })
                event.after.members.filter( member => member.committed === 'yes' && member.commitment === 0).forEach(member => {
                    it('Then committed member ' + member.account +' commitment is 0', async () => {
                        const committedMember= await fetchMember(member.account)
                        assert.equal(committedMember.commitment, 0)
                    })
                    it('Then committed member ' + member.account +' have a potential reward of 0', async () => {
                        const committedMember= await fetchMember(member.account)
                        assert.equal(committedMember.lastEventRewards, 0)
                    })
                    it('Then committed member ' + member.account +' have a balance of ' + member.balance, async () => {
                        const balance= await communityToken.balanceOf(member.account)
                        assert.equal(balance.toNumber(), member.balance)
                    })
                })
                event.after.members.filter( member => member.committed === 'no').forEach(member => {
                    it('Then non committed member ' + member.account +' commitment is still 0', async () => {
                        const committedMember= await fetchMember(member.account)
                        assert.equal(committedMember.commitment, 0)
                    })
                    it('Then non committed member ' + member.account +' receive a potential reward of 0', async () => {
                        const committedMember= await fetchMember(member.account)
                        assert.equal(committedMember.lastEventRewards, 0)
                    })
                    it('Then non committed member ' + member.account +' have a balance of ' + member.balance, async () => {
                        const balance= await communityToken.balanceOf(member.account)
                        assert.equal(balance.toNumber(), member.balance)
                    })
                })
                it('Then balance of community is ' + event.after.community.balance, async () => {
                    const balance= await communityToken.balanceOf(communityContract.address)
                    assert.equal(balance.toNumber(), event.after.community.balance)
                })

            });
        });
    });
});

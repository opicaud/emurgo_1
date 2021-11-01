const Commitment = artifacts.require("Commitment.sol");

contract('Commitment', (accounts) => {
    let commitment;
    it('should initialize the Commitment contract for a community', async function () {
        commitment = await Commitment.deployed();
        assert.isNotNull(commitment);

    });
});


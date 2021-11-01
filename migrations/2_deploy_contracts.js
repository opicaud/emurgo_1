const Commitment = artifacts.require("../contracts/Commitment.sol");

module.exports = async function(deployer) {
    await deployer.deploy(Commitment)

};

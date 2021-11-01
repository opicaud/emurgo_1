const Community = artifacts.require("../contracts/Community.sol");

module.exports = async function(deployer) {
    await deployer.deploy(Community)

};

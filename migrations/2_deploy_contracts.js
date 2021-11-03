const Community = artifacts.require("../contracts/Community.sol");
const CommunityToken = artifacts.require("../contracts/CommunityToken.sol");

module.exports = async function(deployer) {
    await deployer.deploy(CommunityToken);
    const token = await CommunityToken.deployed();
    await deployer.deploy(Community, token.address);

};

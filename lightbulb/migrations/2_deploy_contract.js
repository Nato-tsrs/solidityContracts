const Hero = artifacts.require("IdeaMarketplace");

module.exports = async function (deployer) {
    await deployer.deploy(Hero);
};
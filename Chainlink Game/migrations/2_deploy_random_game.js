const RandomGame = artifacts.require("RandomGame");

module.exports = function (deployer) {
  deployer.deploy(RandomGame);
};

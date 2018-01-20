var WETH10 = artifacts.require("./WETH10.sol");

module.exports = function(deployer) {
  deployer.deploy(WETH10);
};

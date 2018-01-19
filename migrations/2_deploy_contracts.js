//var ERC223 = artifacts.require("ERC223_Interface");
// var SafeMath = artifacts.require("SafeMath");
var WETH10 = artifacts.require("WETH10");

module.exports = function(deployer) {

  deployer.deploy(WETH10);
  
};

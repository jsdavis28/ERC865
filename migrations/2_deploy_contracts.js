var ERC865Token = artifacts.require("./ERC865");

module.exports = function(deployer) {
    deployer.deploy(ERC865Token);
};

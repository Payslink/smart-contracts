const Pays = artifacts.require("Pays");
const Env = require('../env');

module.exports = function (deployer) {
    deployer.deploy(Pays, Env.get('TOKEN_NAME'), Env.get('TOKEN_SYMBOL'));
};

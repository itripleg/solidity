const HDWalletProvider = require('@truffle/HDWallet-Provider');
const privateKey = "583a8292d5bd243bc84b43c9d07c65125c06e0f746faa03d7c8fd40ccb705173";
const rinkebyUrl = "https://speedy-nodes-nyc.moralis.io/a89a5e99c977f7e095a47958/eth/rinkeby";
const kovanUrl = "https://speedy-nodes-nyc.moralis.io/a89a5e99c977f7e095a47958/eth/kovan";

module.exports = {

  networks: {
    rinkeby: {
      provider : ()=>
        new HDWalletProvider({
          privateKeys: [privateKey],
          providerOrUrl: rinkebyUrl,
        }),
        network_id: '4'
    },
    kovan: {
      provider : ()=>
        new HDWalletProvider({
          privateKeys: [privateKey],
          providerOrUrl: kovanUrl,
        }),
        network_id: '42'
    }
  },

  // Set default mocha options here, use special reporters etc.
  mocha: {
    // timeout: 100000
  },

  // Configure your compilers
  compilers: {
    solc: {
      version: "0.8.0",    // Fetch exact version from solc-bin (default: truffle's version)
      // docker: true,        // Use "0.5.1" you've installed locally with docker (default: false)
      // settings: {          // See the solidity docs for advice about optimization and evmVersion
      //  optimizer: {
      //    enabled: false,
      //    runs: 200
      //  },
      //  evmVersion: "byzantium"
      // }
    }
  },

  // Truffle DB is currently disabled by default; to enable it, change enabled: false to enabled: true
  //
  // Note: if you migrated your contracts prior to enabling this field in your Truffle project and want
  // those previously migrated contracts available in the .db directory, you will need to run the following:
  // $ truffle migrate --reset --compile-all

  db: {
    enabled: false
  }
};

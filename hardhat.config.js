require('dotenv').config();
require("@nomicfoundation/hardhat-toolbox");
const prompt=require("prompt-sync")({sigint:true});

const { INFURA_API_URL, SEPOLIA_PRIVATE_KEY, SEPOLIA_PRIVATE_KEY_2 } = process.env;

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.19",
  networks: {
    sepolia: {
      url: INFURA_API_URL,
      accounts: [SEPOLIA_PRIVATE_KEY, SEPOLIA_PRIVATE_KEY_2]
    }
  }

};

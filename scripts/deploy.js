const hre = require("hardhat");
const ethers = hre.ethers;
async function main() {
    const [deployer] = await ethers.getSigners();
  
    console.log("Deploying contracts with the account:", deployer.address);
    
    // make sure to replace the "GoofyGoober" reference with your own ERC-20 name!
    const _contract = await ethers.deployContract("P2PLending")

    await _contract.waitForDeployment();
  
    console.log("Contract address:", _contract.target);
  }
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
  });
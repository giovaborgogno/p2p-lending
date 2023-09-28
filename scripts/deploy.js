const hre = require("hardhat");
async function main() {
    const [deployer] = await hre.ethers.getSigners();
  
    console.log("Deploying contracts with the account:", deployer.address);
    
    // make sure to replace the "GoofyGoober" reference with your own ERC-20 name!
    const _contract = await hre.ethers.deployContract("P2PLending")

    await _contract.waitForDeployment();
  
    console.log("Contract address:", _contract.target);
  }
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
  });
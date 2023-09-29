require('dotenv').config();
const prompt=require("prompt-sync")({sigint:true});
const hre = require("hardhat");
const ethers = hre.ethers;
async function main() {
  const accounts = await ethers.getSigners();

  // set config:
  const config = {
    signer: accounts[1],
    requestId: BigInt(0)
  }

  const contractInfo = {
    name: "P2PLending",
    address: process.env.P2PLendingAddress
  } 
  
  const _accountIndex = prompt("Borrower ('0' or '1'): ")
  const _requestId = prompt("Offer ID: ")
  
  config.signer = accounts[_accountIndex]
  config.requestId = BigInt(_requestId)
  
  console.log("P2PLending [acceptLoanOffer] processing...")
  
  const contract = await ethers.getContractAt(contractInfo.name, contractInfo.address)
  
  const tx = await contract.connect(config.signer).acceptLoanOffer(config.requestId);
  tx.wait();
  
  console.log("success")

  }
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
  });
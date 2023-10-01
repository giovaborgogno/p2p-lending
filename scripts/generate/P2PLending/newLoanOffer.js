require('dotenv').config();
const prompt=require("prompt-sync")({sigint:true});
const hre = require("hardhat");
const ethers = hre.ethers;
async function main() {
  const accounts = await ethers.getSigners();

  // set config:
  const config = {
    signer: accounts[0],
    request: {
      tokenId: BigInt(0),
      amount: BigInt(10e6),
      interest: BigInt(2),
      duration: BigInt(180)
    }
  }

  const contractInfo = {
    name: "P2PLending",
    address: process.env.P2PLendingAddress
  } 

  const _accountIndex = prompt("Lender ('0' or '1'): ")
  const _tokenId = prompt("Token ID ('0' or '1'): ")
  const _amount = prompt("Loan Amount: ")
  const _interest = prompt("Interest: ")
  const _duration = prompt("Duration in seconds: ")
  
  config.signer = accounts[_accountIndex]
  config.request.tokenId = BigInt(_tokenId)
  config.request.amount = BigInt(Number(_amount))
  config.request.interest = BigInt(_interest)
  config.request.duration = BigInt(_duration)
  
  
  console.log("P2PLending [newLoanOffer] processing...")
  
  const contract = await ethers.getContractAt(contractInfo.name, contractInfo.address)
  
  const tx = await contract.connect(config.signer).newLoanOffer(
    config.request.tokenId,
    config.request.amount,
    config.request.interest,
    config.request.duration
    );
  tx.wait();
  
  console.log("success")

  }
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
  });
require('dotenv').config();
const prompt=require("prompt-sync")({sigint:true});
const hre = require("hardhat");
const ethers = hre.ethers;
async function main() {
  const accounts = await ethers.getSigners();
  
  // set this variables:
  const config = {
    signer: accounts[0],
    amount: BigInt(0)
  }
  
  const loanContractAddress = process.env.LoanAddress
  
  const contractInfo = {
    name: "SepoliaUSDCToken",
    address: process.env.SepoliaUSDCTokenAddress
  } 
  
  const _accountIndex = prompt("Account ('0' or '1'): ")
  const _amount = prompt("Amount: ")
  
  config.signer = accounts[_accountIndex]
  config.amount = BigInt(Number(_amount))
  
  console.log("ERC20 [approve] processing...")
  const token = await ethers.getContractAt(contractInfo.name, contractInfo.address)
  const tx = await token.connect(config.signer).approve(loanContractAddress, config.amount);
  tx.wait();
  
  console.log("success")

  }
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
  });
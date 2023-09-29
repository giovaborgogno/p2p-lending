require('dotenv').config();
const prompt=require("prompt-sync")({sigint:true});
const hre = require("hardhat");
const ethers = hre.ethers;
async function main() {
    const accounts = await ethers.getSigners();

    // set config:
    const config = {
        signer: accounts[0],
    }

    const contractInfo = {
        name: "Loan",
        address: process.env.LoanAddress
    }

    const _accountIndex = prompt("Lender ('0' or '1'): ")
    
    config.signer = accounts[_accountIndex]

    console.log("Loan [claimCollateral] processing...")

    const contract = await ethers.getContractAt(contractInfo.name, contractInfo.address)

    const tx = await contract.connect(config.signer).claimCollateral();
    tx.wait();

    console.log("success")

}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
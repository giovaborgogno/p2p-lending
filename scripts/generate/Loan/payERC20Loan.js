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

    const _accountIndex = prompt("Borrower ('0' or '1'): ")
    
    config.signer = accounts[_accountIndex]

    console.log("Loan [payERC20Loan] processing...")

    const contract = await ethers.getContractAt(contractInfo.name, contractInfo.address)

    const tx = await contract.connect(config.signer).payERC20Loan();
    tx.wait();

    console.log("success")

}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
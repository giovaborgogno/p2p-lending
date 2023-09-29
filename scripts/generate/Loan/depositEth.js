require('dotenv').config();
const prompt=require("prompt-sync")({sigint:true});
const hre = require("hardhat");
const ethers = hre.ethers;
async function main() {
    const accounts = await ethers.getSigners();

    // set config:
    const config = {
        signer: accounts[1],
        value: BigInt(6120344293847906)
    }

    const contractInfo = {
        name: "Loan",
        address: process.env.LoanAddress
    }

    const _accountIndex = prompt("Borrower ('0' or '1'): ")
    const _value = prompt("Value Amount: ")
    
    config.signer = accounts[_accountIndex]
    config.value = BigInt(Number(_value))


    console.log("Loan [depositETH] processing...")

    const contract = await ethers.getContractAt(contractInfo.name, contractInfo.address)

    const tx = await contract.connect(config.signer).depositETH({ value: config.value });
    tx.wait();

    console.log("success")

}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
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


    console.log("Loan [loan] processing...")

    const contract = await ethers.getContractAt(contractInfo.name, contractInfo.address)

    const {
        loanToken,
        loanAmount,
        interest,
        repaymentAmount,
        collateralAmount,
        borrower,
        lender,
        loanDuration,
        dueDate,
        active
    } = await contract.connect(config.signer).loan();

    console.log(`
        Token: ${loanToken}
        Amount: ${loanAmount}
        Interst: ${interest}
        Repayment Amount: ${repaymentAmount}
        collateralAmount: ${collateralAmount}
        borrower: ${borrower}
        lender: ${lender}
        duration: ${loanDuration}
        dueDate: ${dueDate}
        active: ${active}`)

    console.log("success")

}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
require('dotenv').config();
const hre = require("hardhat");
const ethers = hre.ethers;
async function main() {

    const { P2PLendingAddress, LoanAddress, SepoliaUSDCTokenAddress, SepoliaDAITokenAddress} = process.env;

    const addressToName = {
        [P2PLendingAddress]: "P2PLending",
        [LoanAddress]: "Loan",
        [SepoliaUSDCTokenAddress]: "SepoliaUSDCToken",
        [SepoliaDAITokenAddress]: "SepoliaDAIToken",
    }

    const contractAddresses = {
        "P2PLending": P2PLendingAddress,
        "Loan": LoanAddress,
        "SepoliaUSDCToken": SepoliaUSDCTokenAddress,
        "SepoliaDAIToken":  SepoliaDAITokenAddress,
    }


    const abis = {
        "P2PLending": [
            "event LoanRequestCreated(uint256 requestId)",
            "event LoanOfferCreated(uint256 offerId)",
            "event LoanCreated(address indexed loan)"
        ],
        "Loan": [
            "event LoanStarted(uint256 date)",
            "event LoanPaid(uint256 date)",
            "event Deposited(address indexed payee, uint256 weiAmount)",
            "event Withdrawn(address indexed payee, uint256 weiAmount)"
        ],
        "SepoliaUSDCToken": [
            "event Transfer(address indexed from, address indexed to, uint256 value)",
            "event Approval(address indexed owner, address indexed spender, uint256 value)"
        ],
        "SepoliaDAIToken": [
            "event Transfer(address indexed from, address indexed to, uint256 value)",
            "event Approval(address indexed owner, address indexed spender, uint256 value)"
        ],
    }

    const events = {
        "P2PLending": {
            "LoanRequestCreated":(requestId) => console.log(`Request ID: ${requestId}`),
            "LoanOfferCreated":(offerId) => console.log(`Offer ID: ${offerId}`),
            "LoanCreated":(loan) => console.log(`Address of Loan Contract:  ${loan}`)
        },
        "Loan": {
            "LoanStarted":(date) => console.log(`Date: ${date}`),
            "LoanPaid":(date) => console.log(`Date: ${date}`),
            "Deposited": (payee, weiAmount) => console.log(`Payee: ${payee}\nWeiAmount: ${weiAmount}`),
            "Withdrawn": (payee, weiAmount) => console.log(`Payee: ${payee}\nWeiAmount: ${weiAmount}`)
        },
        "SepoliaUSDCToken": {
            "Approval": (owner, spender, value) => console.log(`Owner: ${owner}\nSpender: ${spender}\nValue: ${value}`),
            "Transfer": (from, to, value) => console.log(`From: ${from}\nTo: ${to}\nValue: ${value}`),
        },
        "SepoliaDAIToken": {
            "Approval": (owner, spender, value) => console.log(`Owner: ${owner}\nSpender: ${spender}\nValue: ${value}`),
            "Transfer": (from, to, value) => console.log(`From: ${from}\nTo: ${to}\nValue: ${value}`),
        },
    }

    const P2PLending = await ethers.getContractAt(abis["P2PLending"], contractAddresses["P2PLending"])
    const Loan = await ethers.getContractAt(abis["Loan"], LoanAddress)
    const SepoliaUSDCToken = await ethers.getContractAt(abis["SepoliaUSDCToken"], contractAddresses["SepoliaUSDCToken"])
    const SepoliaDAIToken = await ethers.getContractAt(abis["SepoliaDAIToken"], contractAddresses["SepoliaDAIToken"])

    const logEvent = (event) => {
        // console.log(`owner: ${owner}\napproved: ${approved}\nvalue: ${value}`)
        let contractName = addressToName[event.log.address]
        console.log(`\x1b[96mEvent: ${event.fragment.name} | From: ${contractName}\n \x1b[0m`)
        events[contractName][event.fragment.name](...event.log.args)
    } 


    P2PLending.on("*", (event) => logEvent(event))
    Loan.on("*", (event) => logEvent(event))
    SepoliaUSDCToken.on("*", (event) => logEvent(event))
    SepoliaDAIToken.on("*", (event) => logEvent(event))

      console.log("\x1b[32m[LISTENING EVENTS...]\n\x1b[0m")
      await new Promise(resolve => setTimeout(()=>{},86400000));
  }
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
  });
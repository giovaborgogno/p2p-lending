// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

struct LoanStruct {
    IERC20 loanToken;
    uint256 loanAmount;
    uint256 interest;
    uint256 repaymentAmount;
    uint256 collateralAmount;
    address borrower;
    address lender;
    uint256 loanDuration;
    uint256 dueDate;
    bool active;
}
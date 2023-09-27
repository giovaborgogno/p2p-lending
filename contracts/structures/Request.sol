// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

struct Request {
    uint256 id;
    uint256 loanTokenId;
    uint256 loanAmount;
    uint256 interest;
    uint256 loanDuration;
    address borrower;
    address lender;
    bool available;
}

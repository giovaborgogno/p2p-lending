// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../structures/Request.sol";
import "../structures/LoanStruct.sol";
import "../interfaces/ILoan.sol";


interface IP2PLending {

     /**
     * @dev Emitted when `_loan` token is created with a `_loanSctruct`.
     */
    event LoanCreated(ILoan _loan , LoanStruct _loanStruct);

    /**
     * @dev Returns the `_requestId` Loan Request.
     */
    function loanRequest(uint256 _requestId) view external returns(Request memory);

    /**
     * @dev Returns an array of Loan Requests.
     */
    function loanRequests() view external returns(Request[] memory);

    /**
     * @dev Returns the `_offerId` Loan Offer.
     */
    function loanOffer(uint256 _offertId) view external returns(Request memory);

    /**
     * @dev Returns an array of Loan Offers.
     */
    function loanOffers() view external returns(Request[] memory);


    /**
     * @dev Create a New Loan Request from {msg.sender} account with `_loanAmount` amount 
     * of `_loanTokenId` ERC20 token, `_interest` % of interest and `_loanDuration` in seconds.
     *
     * Requirements:
     *
     * - `_loanTokenId` token must exist.
     *
     */
    function newLoanRequest(uint256 _loanTokenId, uint256 _loanAmount, uint256 _interest, uint256 _loanDuration) external returns(uint256);

    /**
     * @dev Create a New Loan Contract from `_loanRequestId` Request.
     *
     * Requirements:
     *
     * - `_loanRequestId` Request must exist and {available}.
     *
     * Emits a {LoanCreated} event.
     */
    function acceptLoanRequest(uint256 _loanRequestId) external returns(ILoan);

    /**
     * @dev Create a New Loan Offer from {msg.sender} account with `_loanAmount` amount 
     * of `_loanTokenId` ERC20 token, `_interest` % of interest and `_loanDuration` in seconds.
     *
     * Requirements:
     *
     * - `_loanTokenId` token must exist.
     *
     */
    function newLoanOffer(uint256 _loanTokenId, uint256 _loanAmount, uint256 _interest, uint256 _loanDuration) external returns(uint256);

    /**
     * @dev Create a New Loan Contract from `_loanOffertId` Offer.
     *
     * Requirements:
     *
     * - `_loanOffertId` Offer must exist and {available}.
     *
     * Emits a {LoanCreated} event.
     */
    function acceptLoanOffer(uint256 _loanOffertId) external returns(ILoan);

}
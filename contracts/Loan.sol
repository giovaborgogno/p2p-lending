// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/escrow/ConditionalEscrow.sol";
import "./interfaces/ILoan.sol";
import "./structures/LoanStruct.sol";


contract Loan is ConditionalEscrow, ILoan {

    // Loan Information
    LoanStruct public loan;

    constructor(LoanStruct memory _loan){
        loan = _loan;
    }

    /**
     * @dev Throws if called by any account other than the borrower.
     */
    modifier onlyBorrower(){
        require(loan.borrower == msg.sender, 'Caller is not the Borrower');
        _;
    }

    /**
     * @dev Throws if called by any account other than the lender.
     */
    modifier onlyLender(){
        require(loan.lender == msg.sender, 'Caller is not the Lender');
        _;
    }

    /**
     * @dev See {ILoan-lendERC20}.
     */
    function lendERC20() public onlyLender {
        /**
     * @dev Moves {loan.loanAmount} {loan.loanToken} from {loan.lender} to {loan.borrower} using the
     * allowance mechanism.
     *
     * Requeriments:
     *
     * - DepositsOf {loan.borrower} must be equal {loan.collateralAmount}.
     * - {loan.false} must be true.
     * - Caller must be the {loan.lender}
     *
     * Emits a {StartLoan} event.
     */

        
    }

    /**
     * @dev See {ILoan-payERC20Loan}.
     */
    function payERC20Loan() public onlyBorrower {
        
    }

    /**
     * @dev See {ILoan-withdrawalAllowed}.
     */
    function withdrawalAllowed(address payee) view public override returns(bool){
        require(!loan.active, "Loan is already active");
    }

    /**
     * @dev See {ILoan-claimCollateral}.
     */
    function claimCollateral() public onlyLender {
        require(block.timestamp > loan.dueDate, "Collateral can't be claimed yet");
        
        uint256 payment = _deposits[loan.borrower];
        _deposits[loan.borrower] = 0;
        loan.lender.sendValue(payment);
        emit Withdrawn(loan.lender, payment);
    }

    /**
     * @dev Set `_dueDate` on Loan Due Date {loan.dueDate}.
     *
     * Requirements:
     *
     * - loan.active must be false.
     *
     */
    function _setDueDate(uint256 _dueDate) internal {
        require(!loan.active, "Loan is already active");

        loan.dueDate = _dueDate;
    }

        /**
     * @dev Set `_active` on Loan Active {loan.active}.
     *
     * Requirements:
     *
     * - loan.active must be false.
     *
     */
    function _setActive(bool _active) internal {
         require(!loan.active, "Loan is already active");

         loan.active = _active;
    }
}
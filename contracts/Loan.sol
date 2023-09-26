// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/escraw/ConditionalEscraw.sol";
import "./intefaces/ILoan.sol";
import "./structures/Loan.sol";


contract Loan is ConditionalEscraw, ILoan {

    // Loan Information
    LoanStruct public loan;

    constructor(LoanStruct _loan){
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
    function lendERC20() payable public onlyLender {}

    /**
     * @dev See {ILoan-payERC20Loan}.
     */
    function payERC20Loan() public onlyBorrower {}

    /**
     * @dev See {ILoan-withdrawalAllowed}.
     */
    function withdrawalAllowed(address payee) public override returns(bool){}

    /**
     * @dev See {ILoan-claimCollateral}.
     */
    function claimCollateral() public onlyLender {}

    /**
     * @dev Set `_dueDate` on Loan Due Date {loan.dueDate}.
     *
     * Requirements:
     *
     * - loan.active must be false.
     *
     */
    function _setDueDate(uint256 _dueDate) internal {}

        /**
     * @dev Set `_active` on Loan Active {loan.active}.
     *
     * Requirements:
     *
     * - loan.active must be false.
     *
     */
    function _setActive(bool _active) internal {}
}
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
    function lendERC20() public onlyLender {}

    /**
     * @dev See {ILoan-payERC20Loan}.
     */
    function payERC20Loan() public onlyBorrower {}

    /**
     * @dev See {ILoan-withdrawalAllowed}.
     */
    function withdrawalAllowed(address payee) view public override returns(bool){}

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
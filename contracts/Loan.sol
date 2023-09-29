// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/escrow/ConditionalEscrow.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "./interfaces/ILoan.sol";
import "./structures/LoanStruct.sol";


contract Loan is ConditionalEscrow, ILoan {

    using Address for address payable;

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

    modifier onlyActive(){
        require(loan.active, "Loan is not active");
        _;
    }

    /**
     * @dev See {ILoan-lendERC20}.
     */
    function depositETH() public payable onlyBorrower {
        require(loan.active == false, "Loan is already active");
        require(loan.loanToken.allowance(loan.lender, address(this)) >= loan.loanAmount, "Lender does not approve the loan yet.");

        deposit(loan.borrower);
        if (depositsOf(loan.borrower) >= loan.collateralAmount){

            require(loan.loanToken.transferFrom(loan.lender, loan.borrower, loan.loanAmount), "Error trasfering ERC20 from lender");
            uint256 _dueDate = block.timestamp + loan.loanDuration;
            
            _setDueDate(_dueDate);
            _setActive(true);

            emit StartLoan(block.timestamp);
        }
        
    }

    /**
     * @dev See {ILoan-payERC20Loan}.
     */
    function payERC20Loan() public onlyBorrower onlyActive {
        require(loan.loanToken.allowance(loan.borrower, address(this)) >= loan.repaymentAmount, "Borrower does not approve the loan yet.");
        require(loan.loanToken.transferFrom(loan.borrower, loan.lender, loan.repaymentAmount), "Error transfering ERC20 from borrower.");

        _setActive(false);
        withdraw(payable (loan.borrower));
        emit LoanPaid(block.timestamp);
        selfdestruct(payable (loan.borrower));

    }

    /**
     * @dev See {ILoan-withdrawalAllowed}.
     */
    function withdrawalAllowed(address payee) view public override returns(bool){
        require(payee == loan.borrower, "Payee is not the borrower.");
        return !loan.active;
    }

    /**
     * @dev See {ILoan-claimCollateral}.
     */
    function claimCollateral() public onlyLender onlyActive {
        require(block.timestamp > loan.dueDate, "Collateral can't be claimed yet");
        
        uint256 payment = depositsOf(loan.borrower);
        address payable payee = payable (loan.lender);
        payee.sendValue(payment);
        emit Withdrawn(loan.lender, payment);
        _setActive(false);
        selfdestruct(payable (loan.lender));
        
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
         loan.active = _active;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface ILoan {

    event StartLoan(uint256 date);
    event LoanPaid(uint256 date);

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
    function lendERC20() external;

    /**
     * @dev Moves {loan.repaymentAmount} {loan.loanToken} from {loan.borrower} to {loan.lender} using the
     * allowance mechanism.
     *
     * Requeriments:
     *
     * - {loan.active} must be true.
     * - Caller must be the {loan.borrower}
     *
     * Emits a {LoanPaid} event.
     */
    function payERC20Loan() external;

    /**
     * @dev Returns whether an address is allowed to withdraw their funds. To be
     * implemented by derived contracts.
     * @param payee The destination address of the funds.
     */
    function withdrawalAllowed(address payee) external returns(bool);

    /**
     * @dev Withdraw accumulated balance for a {loan.lender}, forwarding all gas to the
     * recipient.
     *
     * WARNING: Forwarding all gas opens the door to reentrancy vulnerabilities.
     * Make sure you trust the recipient, or are either following the
     * checks-effects-interactions pattern or using {ReentrancyGuard}.
     *
     * Requirements:
     *
     * - Current Date must be bigger than {loan.dueDate}
     * - Caller must be the {loan.lender}
     *
     * Emits a {Withdrawn} event.
     */
    function claimCollateral() external;
}
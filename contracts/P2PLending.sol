// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "./interfaces/IP2PLending.sol";
import "./interfaces/ILoan.sol";
import "./structures/Request.sol";
import "./structures/LoanStruct.sol";
import "./Loan.sol";


contract P2PLending is IP2PLending {

    using Counters for Counters.Counter;
    Counters.Counter private _requestIdTracker;
    Counters.Counter private _offerIdTracker;
    Counters.Counter private _loanTokenIdTracker;

    // DEFAULT Price Feed Contract Addresses CHAINLINK
    // (BTC/USD)/(EUR/USD) = BTC/EUR
    AggregatorV3Interface constant private ETH_USD = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
    AggregatorV3Interface constant private USDC_USD = AggregatorV3Interface(0xA2F78ab2355fe2f984D808B5CeE7FD0A93D5270E);
    AggregatorV3Interface constant private DAI_USD = AggregatorV3Interface(0x14866185B1962B63C3Ea9E03Bc1da838bab34C19);

    // Address contracts for ERC20 tokens
    IERC20 constant private USDC = IERC20(0xcD6a42782d230D7c13A74ddec5dD140e55499Df9);
    IERC20 constant private DAI = IERC20(0xcD6a42782d230D7c13A74ddec5dD140e55499Df9);

    // Mapping from token ID to token address contract
    mapping(uint256 => IERC20) private _loanTokens;

    // Mapping from ERC20 token to Price Feed Contract Address
    mapping(IERC20 => AggregatorV3Interface) private _priceFeedContractAddresses;

    // Mapping from request ID to requests
    mapping(uint256 => Request) private _loanRequests;

    // Mapping from offer ID to offers
    mapping(uint256 => Request) private _loanOffers;

    constructor(){
        // USDC ID = 0;
        _loanTokens[_loanTokenIdTracker.current()] = USDC;
        _loanTokenIdTracker.increment();
        
        // USDC ID = 1;
        _loanTokens[_loanTokenIdTracker.current()] = DAI;
        _loanTokenIdTracker.increment();

        _priceFeedContractAddresses[USDC] = USDC_USD;
        _priceFeedContractAddresses[DAI] = DAI_USD;
    }

    modifier loanTokenIdExists(uint256 _loanTokenId){
        require(_loanTokens[_loanTokenId] != IERC20(address(0)), 'Loan Token Id does not exists');
        _;
    }

    /**
     * @dev See {IP2PLending-loanRequest}.
     */
    function loanRequest(uint256 _requestId) view public returns(Request memory){
        return _loanRequests[_requestId];
    }

    /**
     * @dev See {IP2PLending-loanRequests}.
     */
    function loanRequests() view public returns(Request[] memory){}

    /**
     * @dev See {IP2PLending-loanOffer}.
     */
    function loanOffer(uint256 _offertId) view public returns(Request memory){
        return _loanOffers[_offertId];
    }

    /**
     * @dev See {IP2PLending-loanOffers}.
     */
    function loanOffers() view public returns(Request[] memory){}

    /**
     * @dev See {IP2PLending-newLoanRequest}.
     */
    function newLoanRequest(uint256 _loanTokenId, uint256 _loanAmount, uint256 _interest, uint256 _loanDuration) public loanTokenIdExists(_loanTokenId) returns(uint256){

        uint256 _id = _requestIdTracker.current();
        Request memory _newRequest = Request(
            _id,
            _loanTokenId,
            _loanAmount,
            _interest,
            _loanDuration,
            msg.sender,
            true
        );

        _loanRequests[_id] = _newRequest;

        return _id;

    }

    /**
     * @dev See {IP2PLending-acceptLoanRequest}.
     */
    function acceptLoanRequest(uint256 _loanRequestId) public returns(ILoan) {
        Request storage _request = _loanRequests[_loanRequestId];
        require(_request.borrower != address(0) && _request.available == true);

        _request.available = false;
        _request.lender = msg.sender;

        ILoan _iloan = _newLoan(_request);

        return _iloan;

    }

    /**
     * @dev See {IP2PLending-newLoanOffer}.
     */
    function newLoanOffer(uint256 _loanTokenId, uint256 _loanAmount, uint256 _interest, uint256 _loanDuration) public loanTokenIdExists(_loanTokenId) returns(uint256){
        uint256 _id = _offerIdTracker.current();
        Request memory _newOffer = Request(
            _id,
            _loanTokenId,
            _loanAmount,
            _interest,
            _loanDuration,
            msg.sender,
            true
        );

        _loanOffers[_id] = _newOffer;

        return _id;
    }

    /**
     * @dev See {IP2PLending-acceptLoanOffer}.
     */
    function acceptLoanOffer(uint256 _loanOffertId) public {}

    /** @dev Calculate the Weis Collateral Amount using Chain Link Price Feed Contracts.
     * @param _loanAmount Loan Amount.
     * @param _loanTokenId ERC20 token Id
     *
     * Requirements:
     *
     * - `_loanTokenId` must exists in {_loanTokens}
     *
     */
    function _calculateCollateralAmount(uint256 _loanAmount, uint256 _loanTokenId)internal returns(uint256){}

     /** @dev Calculate the Repayment Amount using `_interest` porcentage.
     * @param _loanAmount Loan Amount.
     * @param _interest interest porcentage
     *
     */
    function _calculateRepaymentAmount(uint256 _loanAmount, uint256 _interest)internal returns(uint256){}

     /** @dev Calculate the Weis Collateral Amount using Chain Link Price Feed Contracts.
     * @param _request Request.
     *
     */
    function _newLoan(Request _request)internal returns(ILoan){

        uint256 _collateralAmount = _calculateCollateralAmount(_request.loanAmount, _request._loanTokenId);
        uint256 _repaymentAmount = _calculateRepaymentAmount(_request.loanAmount, _request.interest);

        LoanStruct memory _loanStruct = LoanStruct({
            loanToken: _loanTokens[_request._loanTokenId],
            loanAmount: _request.loanAmount,
            interest: _request.interest,
            repaymentAmount: _repaymentAmount,
            collateralAmount: _collateralAmount,
            borrower: _request.borrower,
            lender: _request.lender,
            loanDuration: _request.loanDuration,
            dueDate: block.timestamp + _request.loanDuration,
            active: false
        });

        Loan memory _loan = new Loan(_loanStruct);

        emit LoanCreated(ILoan(_loan), _loanStruct);

        return ILoan(_loan);
    }


}
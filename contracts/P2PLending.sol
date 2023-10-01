// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "./interfaces/IP2PLending.sol";
import "./interfaces/ILoan.sol";
import "./structures/Request.sol";
import "./structures/LoanStruct.sol";
import "./Loan.sol";

abstract contract IERC20Extented is IERC20 {     
    function decimals() public virtual view returns (uint8); 
}

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
    IERC20 constant private USDC = IERC20(0x82346f167B2b938A56AFdb694753C5BA7A2ab550);
    IERC20 constant private DAI = IERC20(0x76c1De9Af029966200F4F572F5D0c180259cfce4);

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
    function loanRequests() view public returns(Request[] memory){
        uint256 arrLength = _requestIdTracker.current();
        Request[] memory AllRequests = new Request[](arrLength);
        
        for (uint256 i = 0; i < arrLength; i++) {
            AllRequests[i] = _loanRequests[i];
        }

        return AllRequests;
    }

    /**
     * @dev See {IP2PLending-loanOffer}.
     */
    function loanOffer(uint256 _offertId) view public returns(Request memory){
        return _loanOffers[_offertId];
    }

    /**
     * @dev See {IP2PLending-loanOffers}.
     */
    function loanOffers() view public returns(Request[] memory){
        uint256 arrLength = _offerIdTracker.current();
        Request[] memory AllOffers = new Request[](arrLength);
        
        for (uint256 i = 0; i < arrLength; i++) {
            AllOffers[i] = _loanOffers[i];
        }

        return AllOffers;
    }

    /**
     * @dev See {IP2PLending-newLoanRequest}.
     */
    function newLoanRequest(uint256 _loanTokenId, uint256 _loanAmount, uint256 _interest, uint256 _loanDuration) public loanTokenIdExists(_loanTokenId){

        uint256 _id = _requestIdTracker.current();
        _requestIdTracker.increment();

        Request memory _newRequest = Request({
            id: _id,
            loanTokenId: _loanTokenId,
            loanAmount: _loanAmount,
            interest: _interest,
            loanDuration: _loanDuration,
            borrower: msg.sender,
            lender: address(0),
            available: true
        });

        _loanRequests[_id] = _newRequest;

        emit LoanRequestCreated(_id);

    }

    /**
     * @dev See {IP2PLending-acceptLoanRequest}.
     */
    function acceptLoanRequest(uint256 _loanRequestId) public {
        Request storage _request = _loanRequests[_loanRequestId];
        require(_request.borrower != address(0) && _request.available == true, "Request is not available");
        require(_request.borrower != msg.sender, "Borrower and Lender are the same address account");

        _request.available = false;
        _request.lender = msg.sender;

        _newLoan(_request);

    }

    /**
     * @dev See {IP2PLending-newLoanOffer}.
     */
    function newLoanOffer(uint256 _loanTokenId, uint256 _loanAmount, uint256 _interest, uint256 _loanDuration) public loanTokenIdExists(_loanTokenId){
        uint256 _id = _offerIdTracker.current();
        _offerIdTracker.increment();

        Request memory _newOffer = Request({
            id: _id,
            loanTokenId: _loanTokenId,
            loanAmount: _loanAmount,
            interest: _interest,
            loanDuration: _loanDuration,
            borrower: address(0),
            lender: msg.sender,
            available: true
        });

        _loanOffers[_id] = _newOffer;

        emit LoanOfferCreated(_id);
    }

    /**
     * @dev See {IP2PLending-acceptLoanOffer}.
     */
    function acceptLoanOffer(uint256 _loanOffertId) public{
        Request storage _offer = _loanOffers[_loanOffertId];
        require(_offer.lender != address(0) && _offer.available == true, "Offer is not available");
        require(_offer.lender != msg.sender, "Borrower and Lender are the same address account");

        _offer.available = false;
        _offer.borrower = msg.sender;

        _newLoan(_offer);
    }

    /** @dev Calculate the Weis Collateral Amount using Chain Link Price Feed Contracts.
     * @param _loanAmount Loan Amount.
     * @param _loanTokenId ERC20 token Id
     *
     * Requirements:
     *
     * - `_loanTokenId` must exists in {_loanTokens}
     *
     */
    function _calculateCollateralAmount(uint256 _loanAmount, uint256 _interest, uint256 _loanTokenId)internal view returns(uint256){
        IERC20 ierc20 = _loanTokens[_loanTokenId];
        AggregatorV3Interface ERC20_USD = _priceFeedContractAddresses[ierc20];

        IERC20Extented ierc20Extended = IERC20Extented(address(ierc20));
        uint8 decimals = ierc20Extended.decimals();

        int256 derivatedPrice = _getDerivedPrice(ETH_USD, ERC20_USD, decimals);
        uint256 repaymentAmount = _calculateRepaymentAmount(_loanAmount, _interest);

        return (repaymentAmount * (10 ** 18)) / uint256(derivatedPrice);
    }

    function _getDerivedPrice(AggregatorV3Interface _base, AggregatorV3Interface _quote, uint8 _decimals) internal view returns (int256) {
        require(
            _decimals > uint8(0) && _decimals <= uint8(18),
            "Invalid _decimals"
        );
        int256 decimals = int256(10 ** uint256(_decimals));
        (, int256 basePrice, , , ) = _base.latestRoundData();
        uint8 baseDecimals = _base.decimals();
        basePrice = _scalePrice(basePrice, baseDecimals, _decimals);

        (, int256 quotePrice, , , ) = _quote.latestRoundData();
        uint8 quoteDecimals = _quote.decimals();
        quotePrice = _scalePrice(quotePrice, quoteDecimals, _decimals);

        return (basePrice * decimals) / quotePrice;
    }

    function _scalePrice(int256 _price, uint8 _priceDecimals, uint8 _decimals) internal pure returns (int256) {
        if (_priceDecimals < _decimals) {
            return _price * int256(10 ** uint256(_decimals - _priceDecimals));
        } else if (_priceDecimals > _decimals) {
            return _price / int256(10 ** uint256(_priceDecimals - _decimals));
        }
        return _price;
    }

     /** @dev Calculate the Repayment Amount using `_interest` porcentage.
     * @param _loanAmount Loan Amount.
     * @param _interest interest porcentage
     *
     */
    function _calculateRepaymentAmount(uint256 _loanAmount, uint256 _interest)pure internal returns(uint256){
        uint256 repaymentAmount = _loanAmount + (_loanAmount * _interest)/100;
        return repaymentAmount;
    }

     /** @dev Create a new Loan Contract.
     * @param _request Request.
     *
     */
    function _newLoan(Request memory _request)internal{
        require(_request.borrower != address(0) && _request.lender != address(0), "Borrower or Lender is not valid.");
        require(_request.borrower != _request.lender, "Borrower and Lender are the same address account");

        uint256 _collateralAmount = _calculateCollateralAmount(_request.loanAmount, _request.interest, _request.loanTokenId);
        uint256 _repaymentAmount = _calculateRepaymentAmount(_request.loanAmount, _request.interest);

        LoanStruct memory _loanStruct = LoanStruct({
            loanToken: _loanTokens[_request.loanTokenId],
            loanAmount: _request.loanAmount,
            interest: _request.interest,
            repaymentAmount: _repaymentAmount,
            collateralAmount: _collateralAmount,
            borrower: _request.borrower,
            lender: _request.lender,
            loanDuration: _request.loanDuration,
            dueDate: 0,
            active: false
        });

        Loan _loan = new Loan(_loanStruct);

        emit LoanCreated(address(_loan));

        _loan.transferOwnership(_request.borrower);

    }


}
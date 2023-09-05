// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "../interface/IPinecore.sol";
import "../interface/IRangeOrder.sol";

contract Tradix is Ownable {
    //Address of the fund receiver
    address private maintainerAddress;
    address public GelatoPineCoreAddress;
    address public RangeOrder;

    event EthDeposited(
        address indexed sender,
        uint256 amount,
        bytes data,
        uint256 maintainerFee
    );
    event RangeOrderSet(
        address indexed sender,
        IUniswapV3Pool indexed pool,
        bool zeroForOne,
        int24 tickThreshold,
        uint256 amountIn,
        uint256 minLiquidity,
        address receiver,
        uint256 maxFeeAmount,
        uint256 valueSent
    );

    struct RangeOrderParams {
        IUniswapV3Pool pool;
        bool zeroForOne;
        int24 tickThreshold;
        uint256 amountIn;
        uint256 minLiquidity;
        address payable receiver;
        uint256 maxFeeAmount;
    }
    modifier ZeroAddress(address _account) {
        require(_account != address(0), "TRDX:Invalid address");
        _;
    }

    constructor(address _gelatoPineCoreAddress, address _rangeOrder) {
        GelatoPineCoreAddress = _gelatoPineCoreAddress;
        RangeOrder = _rangeOrder;
    }

    /**
     * @dev Function to deposit Ether into the GelatoPineCore contract and transfer maintainer fee.
     * @param _data Additional data to be passed to the GelatoPineCore contract .
     * @param _maintainerFee The amount of Ether to be transferred to the maintainer as a fee for using this contract.
     */

    function depositEth(
        bytes calldata _data,
        uint256 _maintainerFee
    ) external payable {
        require(msg.value > _maintainerFee, "TRDX: Invalid Eth Amount");

        uint256 tValue = msg.value - _maintainerFee;

        (bool success, ) = maintainerAddress.call{value: _maintainerFee}("");
        require(success, "TRDX: Transfer Failed");

        IPineCore(GelatoPineCoreAddress).depositEth{value: tValue}(_data);

        emit EthDeposited(msg.sender, tValue, _data, _maintainerFee);
    }

    function setRangeOrder(
        IRangeOrder.RangeOrderParams memory _params
    ) external payable {
        IRangeOrder.RangeOrderParams memory params = IRangeOrder
            .RangeOrderParams({
                pool: _params.pool,
                zeroForOne: _params.zeroForOne,
                tickThreshold: _params.tickThreshold,
                amountIn: _params.amountIn,
                minLiquidity: _params.minLiquidity,
                receiver: _params.receiver,
                maxFeeAmount: _params.maxFeeAmount
            });

        IRangeOrder(RangeOrder).setRangeOrder{value: msg.value}(params);
        emit RangeOrderSet(
            msg.sender,
            _params.pool,
            _params.zeroForOne,
            _params.tickThreshold,
            _params.amountIn,
            _params.minLiquidity,
            _params.receiver,
            _params.maxFeeAmount,
            msg.value
        );
    }

    function setMaintainerAddress(
        address _account
    ) external onlyOwner ZeroAddress(_account) {
        maintainerAddress = _account;
    }

    function setGelatoPineCoreAddress(
        address _gelatoPineCoreAddress
    ) external onlyOwner ZeroAddress(_gelatoPineCoreAddress) {
        GelatoPineCoreAddress = _gelatoPineCoreAddress;
    }

    function setRangeOrderAddress(
        address _rangeOrder
    ) external onlyOwner ZeroAddress(_rangeOrder) {
        RangeOrder = _rangeOrder;
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IERC20.sol";
import "../interface/IOrderRouter.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../interface/IPinecore.sol";

contract Tradix is Ownable {
    // Address of the fund receiver
    address public UNISWAP_V2_ROUTER;

    // Address of WETH token
    address public WETH;
    // Address of the fund receiver
    address public maintainerAddress;
    address public OrderRouter;

    address public GelatoPineCoreAddress;

    event EthDeposited(
        address indexed sender,
        uint256 amount,
        bytes data,
        uint256 maintainerFee
    );

    event TokenDeposited(
        address indexed sender,
        uint256 amount,
        uint256 feeAmount,
        uint256 amountOutMin,
        address module,
        address inputToken,
        address owner,
        address witness,
        bytes data,
        bytes32 secret,
        bool taxable
    );

    modifier ZeroAddress(address _account) {
        require(_account != address(0), "TRDX: Invalid address");
        _;
    }

    constructor(
        address _orderRouter,
        address _gelatoPineCoreAddress,
        address _router,
        address _Weth,
        address _maintainerAddress
    )
        ZeroAddress(_orderRouter)
        ZeroAddress(_gelatoPineCoreAddress)
        ZeroAddress(_router)
        ZeroAddress(_Weth)
        ZeroAddress(_maintainerAddress)
    {
        OrderRouter = _orderRouter;
        GelatoPineCoreAddress = _gelatoPineCoreAddress;
        UNISWAP_V2_ROUTER = _router;
        WETH = _Weth;
        maintainerAddress = _maintainerAddress;
    }

    /**
     * @dev Function to deposit Ether into the GelatoPineCore contract and transfer maintainer fee.
     * @param _data Additional data to be passed to the GelatoPineCore contract.
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

    /**
     * @dev Function to deposit tokens into the GelatoPineCore contract and transfer a fee in tokens.
     * @param _amount The amount of tokens to deposit.
     * @param _feeAmount The amount of tokens to transfer as a fee.
     * @param _amountOutMin The minimum amount of ETH to receive in exchange for tokens.
     * @param _module The address of the module.
     * @param _inputToken The address of the token to deposit.
     * @param _owner The address of the owner.
     * @param _witness The address of the witness.
     * @param _data Additional data to be passed to the GelatoPineCore contract.
     * @param _secret A secret value.
     * @param _taxable A flag indicating if the token transfer is taxable.
     */
    function depositToken(
        uint256 _amount,
        uint256 _feeAmount,
        uint256 _amountOutMin,
        address _module,
        address _inputToken,
        address payable _owner,
        address _witness,
        bytes calldata _data,
        bytes32 _secret,
        bool _taxable
    ) external {
        address[] memory path = new address[](2);
        path[0] = _inputToken;
        path[1] = WETH;

        IERC20(_inputToken).transferFrom(msg.sender, address(this), _feeAmount);
        IERC20(_inputToken).approve(UNISWAP_V2_ROUTER, _feeAmount);
        if (_taxable) {
            IUniswapV2Router02(UNISWAP_V2_ROUTER)
                .swapExactTokensForETHSupportingFeeOnTransferTokens(
                    IERC20(_inputToken).balanceOf(address(this)),
                    _amountOutMin,
                    path,
                    maintainerAddress,
                    block.timestamp
                );
        } else {
            IUniswapV2Router02(UNISWAP_V2_ROUTER).swapExactTokensForETH(
                _feeAmount,
                _amountOutMin,
                path,
                maintainerAddress,
                block.timestamp
            );
        }

        IOrderRouter(OrderRouter).depositToken(
            _amount,
            _module,
            _inputToken,
            _owner,
            _witness,
            _data,
            _secret
        );

        emit TokenDeposited(
            msg.sender,
            _amount,
            _feeAmount,
            _amountOutMin,
            _module,
            _inputToken,
            _owner,
            _witness,
            _data,
            _secret,
            _taxable
        );
    }

    /**
     * @dev Function to set the maintainer address.
     * @param _account The new maintainer address.
     */
    function setMaintainerAddress(
        address _account
    ) external onlyOwner ZeroAddress(_account) {
        maintainerAddress = _account;
    }

    /**
     * @dev Function to set the OrderRouter address.
     * @param _orderRouter The new OrderRouter address.
     */
    function setOrderRouter(
        address _orderRouter
    ) external onlyOwner ZeroAddress(_orderRouter) {
        OrderRouter = _orderRouter;
    }

    /**
     * @dev Function to set the gelatoPineCoreAddress address.
     * @param _gelatoPineCoreAddress The new OrderRouter address.
     */

    function setGelatoPineCoreAddress(
        address _gelatoPineCoreAddress
    ) external onlyOwner ZeroAddress(_gelatoPineCoreAddress) {
        GelatoPineCoreAddress = _gelatoPineCoreAddress;
    }

    function setUNISWAPROUTER(
        address _uniswaoRouter
    ) external onlyOwner ZeroAddress(_uniswaoRouter) {
        UNISWAP_V2_ROUTER = _uniswaoRouter;
    }

    function setWETH(address _weth) external onlyOwner ZeroAddress(_weth) {
        WETH = _weth;
    }
}

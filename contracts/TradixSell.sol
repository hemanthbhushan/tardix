// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IERC20.sol";

import "@openzeppelin/contracts/access/Ownable.sol";
import "../interface/IOrderRouter.sol";

contract Tradix is Ownable {
    // Address of the Uniswap v2 router
    address public UNISWAP_V2_ROUTER;

    // Address of WETH token
    address public WETH;
    //Address of the fund receiver
    address private maintainerAddress;
    address public OrderRouter;

    modifier ZeroAddress(address _account) {
        require(_account != address(0), "TRDX:Invalid address");
        _;
    }

    constructor(address _orderRouter, address _router, address _Weth) {
        OrderRouter = _orderRouter;
        UNISWAP_V2_ROUTER = _router;
        WETH = _Weth;
    }

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
    }

    function setMaintainerAddress(
        address _account
    ) external onlyOwner ZeroAddress(_account) {
        maintainerAddress = _account;
    }

    function setOrderRouter(
        address _orderRouter
    ) external onlyOwner ZeroAddress(_orderRouter) {
        OrderRouter = _orderRouter;
    }
}

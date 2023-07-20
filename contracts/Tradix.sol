// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "../interface/IGelatoPineCore.sol";

import "@openzeppelin/contracts/access/Ownable.sol";
import "./MockRouter/interfaces/IUniswapV2Router02.sol";

contract Tradix is Ownable {
    //Address of the fund receiver
    address private platformAddress;
    address private maintainerAddress;
    address public GelatoPineCoreAddress;
    address public WETH;
    address public UNISWAP_V2_ROUTER;

    modifier ZeroAddress(address _account) {
        require(_account != address(0), "TRDX:Invalid address");
        _;
    }

    constructor(
        address _gelatoPineCoreAddress,
        address _weth,
        address _router
    ) {
        GelatoPineCoreAddress = _gelatoPineCoreAddress;
        WETH = _weth;
        UNISWAP_V2_ROUTER = _router;
    }

    function executeOrder(
        IModule _module,
        IERC20 _inputToken,
        address payable _owner,
        bytes calldata _data,
        bytes calldata _signature,
        bytes calldata _auxData,
        uint256 _tokenAmount,
        uint256 _amountOutMin
    ) external payable onlyOwner {
        uint256 amount;
        if (_tokenAmount == 0) {
            (
                uint256 _maintainerFee,
                uint256 _platformFee
            ) = percentageCalculation(msg.value);
            (bool success, ) = maintainerAddress.call{value: _maintainerFee}(
                ""
            );
            require(success, "TRDX:ETH transfer failed To Maintainer");
            success = false;
            (success, ) = platformAddress.call{value: _platformFee}("");
            require(success, "TRDX:ETH transfer failed To Platform");
        } else {
            // Construct the token swap path
            address[] memory path = new address[](2);
            path[0] = address(_inputToken);
            path[1] = WETH;

            IERC20(_inputToken).transferFrom(
                msg.sender,
                address(this),
                _tokenAmount
            );
            IERC20(_inputToken).approve(UNISWAP_V2_ROUTER, _tokenAmount);

            amount = IUniswapV2Router02(UNISWAP_V2_ROUTER)
                .swapExactTokensForETH(
                    _tokenAmount,
                    _amountOutMin,
                    path,
                    address(this),
                    block.timestamp
                )[1];

            (
                uint256 _maintainerFee,
                uint256 _platformFee
            ) = percentageCalculation(amount);

            (bool success, ) = maintainerAddress.call{value: _maintainerFee}(
                ""
            );
            require(success, "ETH transfer failed To Maintainer");
            success = false;
            (success, ) = platformAddress.call{value: _platformFee}("");
            require(success, "ETH transfer failed To Platform");
        }

        IGelatoPineCore(GelatoPineCoreAddress).executeOrder(
            _module,
            _inputToken,
            _owner,
            _data,
            _signature,
            _auxData
        );
    }

    /**
     * @dev Calculates various percentages and amounts based on the input value.
     * @param _amountIn The input amount to perform calculations on.
     * @return maintanierFee The maintenance fee calculated as 40% of the deduction amount.
     * @return platformFee The platform fee calculated as the difference between the deduction amount and the maintainer fee.

     */

    function percentageCalculation(
        uint256 _amountIn
    ) internal pure returns (uint256 maintanierFee, uint256 platformFee) {
        maintanierFee = (_amountIn * 40) / 100;
        platformFee = _amountIn - maintanierFee;
    }

    function setPlatformAddress(
        address _account
    ) external onlyOwner ZeroAddress(_account) {
        platformAddress = _account;
    }

    function setMaintainerAddress(
        address _account
    ) external onlyOwner ZeroAddress(_account) {
        maintainerAddress = _account;
    }
}

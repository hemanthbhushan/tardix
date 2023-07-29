// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// import "../interface/IGelatoPineCore.sol";

import "@openzeppelin/contracts/access/Ownable.sol";
import "./MockRouter/interfaces/IUniswapV2Router02.sol";
import "../interface/IPinecore.sol";

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

    function depositEth(
        bytes calldata _data,
        uint256 _maintainerFee
    ) external payable {
        require(msg.value > _maintainerFee, "TRDX: Invalid Eth Amount");

        uint256 tValue = msg.value - _maintainerFee;

        (bool success, ) = maintainerAddress.call{value: _maintainerFee}("");
        require(success, "TRDX: Transfer Failed");

        IPineCore(GelatoPineCoreAddress).depositEth{value: tValue}(_data);
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

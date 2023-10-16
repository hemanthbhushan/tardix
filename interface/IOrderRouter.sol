// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

interface IOrderRouter {
    function depositToken(
        uint256 _amount,
        address _module,
        address _inputToken,
        address payable _owner,
        address _witness,
        bytes calldata _data,
        bytes32 _secret
    ) external;
}

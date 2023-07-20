// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "./IModule.sol";

interface IGelatoPineCore {
    function executeOrder(
        IModule _module,
        IERC20 _inputToken,
        address payable _owner,
        bytes calldata _data,
        bytes calldata _signature,
        bytes calldata _auxData
    ) external;
}

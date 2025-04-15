// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

contract TPUProxy is TransparentUpgradeableProxy {
    constructor(address _impl,address initOwner, bytes memory _data) 
    payable 
    TransparentUpgradeableProxy(
        _impl,
        initOwner,
        _data
    ) {

    }

    function proxyAdmin() external view returns(address){
        return _proxyAdmin();
    }

    function getImplements() external view returns(address){
        return _implementation();
    }
}
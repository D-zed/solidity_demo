// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract MyEnum {
    enum Status {
        None,
        Pending,
        Shipped,
        Completed,
        Rejected,
        Canceled
    }
    //状态变量
    Status public status;

    struct Order {
        address buyer;
        Status status;
    }

    Order [] public orders;

    function get() external view returns (Status) {
        return status;
    }

    function set(Status _status) external {
        status=_status;
    }

    function ship() external {
        status = Status.Shipped;
    }

    function reset() external {
        delete status;
    }
}
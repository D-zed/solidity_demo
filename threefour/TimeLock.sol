// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract TimeLock {

    event Queue(bytes32 indexed txId,address indexed _target,uint _value,string _func,bytes _data,uint _timestamp);
    event Execute(bytes32 indexed txId,address indexed _target,uint _value,string _func,bytes _data,uint _timestamp);
    event Cancel(bytes32 indexed txId);


    error NotOwnerError();

    error AlreadyQueuedError();

    error TimestampNotInRangeError(uint blockTimestamp,uint timestamp);

    error NotQueueError(bytes32 txId);

    error TimestampNotPassedError(uint blockTimestamp,uint timestamp);
    
    error TimestampExpiredERROR(uint blockTimestamp,uint expired);

    error TxFailError();
    

    uint public  constant MIN_DELAY=10;
    uint public constant MAX_DELAY=1000;

    uint public constant GRACE_PERIOD=1000;
    address public owner;

    mapping (bytes32=> bool) public queued;

    constructor(){
        owner=msg.sender;
    }

    receive() external payable { }

    modifier onlyOwner(){
        if (msg.sender!=owner){
            revert NotOwnerError();
        }
        _;
    }

    function getTxId(
        address _target,
        uint _value,
        string calldata _func,
        bytes calldata _data,
        uint _timestamp
    ) public pure returns(bytes32 txId){
        return keccak256(
            abi.encode(_target,_value,_func,_data,_timestamp)
        );
    }


    function queue(
        address _target,
        uint _value,
        string calldata _func,
        bytes calldata _data,
        uint _timestamp
    ) external {

        bytes32 txId = getTxId(_target, _value, _func, _data, _timestamp);
        //check txId unique
        if(queued[txId]){
            revert AlreadyQueuedError();
        }
        //check timestamp
        if(_timestamp < block.timestamp+MIN_DELAY||
            _timestamp > block.timestamp+MAX_DELAY
        ){
            revert TimestampNotInRangeError(block.timestamp,_timestamp);
        }
        //queue tx
        queued[txId]=true;

        emit Queue(txId,_target,_value, _func, _data,_timestamp);
    }

    function execute(
        address _target,
        uint _value,
        string calldata _func,
        bytes calldata _data,
        uint _timestamp
    ) external payable onlyOwner returns (bytes memory){
        // create tx id
        bytes32 txId = getTxId(_target, _value, _func, _data, _timestamp);
        // check tx id unique
         if(!queued[txId]){
            revert NotQueueError(txId);
         }
        // check block.timestamp > _timestamp
        if( block.timestamp < _timestamp){
            revert TimestampNotPassedError(block.timestamp,_timestamp);
         }
         if (block.timestamp > _timestamp +GRACE_PERIOD){
            revert TimestampExpiredERROR(block.timestamp,_timestamp+GRACE_PERIOD);
         }
        // delete tx from queue
        queued[txId] = false;

        // execute the tx
        bytes memory data;
        if (bytes(_func).length>0){
            //紧凑型编码 不会补位，如果是encode的话会强制补0到32字节
            data=abi.encodePacked(
                //强制截取4字节的数组
                bytes4(
                    //32字节
                    keccak256(bytes(_func))
                    )
            );
        }else {
            data=_data;
        }
        (bool success,bytes memory res) =_target.call{value:_value}(
            data
        );
        if(!success){
            revert TxFailError();
        }
        
        emit Execute(txId,_target,_value, _func, _data,_timestamp);

        return res;
    }

    function cancel(bytes32 _txId) external onlyOwner{
        if(!queued[_txId]){
            revert NotQueueError(_txId);
        }
        queued[_txId] = false;
        emit Cancel(_txId);
    }
}

contract TestTimeLock{

    address public timeLock;

    constructor(address _timeLock){
        timeLock = _timeLock;
    }

    function test() external {
        require(msg.sender == timeLock);
        /*
        - 升级合约
        - 转移资产
        - 修改预言机
        */
    }

    function getTimestamp() external returns(uint){
        return block.timestamp+100;
    }

}
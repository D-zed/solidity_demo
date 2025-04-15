// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface IERC721 {
    function transferFrom(address _from,
        address _to,
        uint _nftId) external ;
}

contract DutchAuction{
    uint private constant DURATION=7 days;

    IERC721 public immutable nft;
    uint public immutable nftId;
    address public  immutable seller;
    uint public  immutable startingPrice;
    uint public  immutable startAt;
    uint public  immutable expiresAt;
    uint public  immutable discountRate;

    constructor(uint _startingPrice,uint _discountRate,address _nft,uint _nftId){
        seller=payable(msg.sender);
        startingPrice=_startingPrice;
        discountRate=_discountRate;
        startAt=block.timestamp;
        expiresAt=block.timestamp+DURATION;
        require(_startingPrice>=_discountRate*DURATION,"startingprice<discount");
        //将地址转为合约
        nft=IERC721(_nft);
        nftId=_nftId;
    }

    function getPrice() public view returns(uint){  
        //过去的时间
        uint timeElapsed = block.timestamp - startAt;
        //折扣
        uint discount=discountRate*timeElapsed;
        return startingPrice-discount;
    }

    function buy() external payable {
        require(block.timestamp<expiresAt,"finished");
        uint price=getPrice();
        require(msg.value>=price,"not enough money");
        nft.transferFrom(seller,msg.sender,nftId);
        uint refund=msg.value-price;
        if(refund>0){
            //如果金额都超过了，则退费
            payable(msg.sender).transfer(refund);
        }
    }
    
}
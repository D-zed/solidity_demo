// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface IERC20 {
    function transfer(address,uint256) external returns(bool);

    function transferFrom(address,address,uint256) external returns(bool);
}

contract CrowdFund{

    //活动
    struct Campaign {
        address creator;
        uint goal;  //众筹金额
        uint pledged;
        uint startAt;
        uint endAt;
        bool claimed;  //申领
    }

    event Launch(uint id,address indexed creator,uint goal,uint32 startAt,uint32 endAt);
    event Cancel(uint id);
    event Pledge(uint indexed id,address indexed caller,uint indexed amount);
    event UnPledge(uint indexed id,address indexed caller,uint indexed amount);
    event Claim(uint id,address indexed creator,uint indexed amount);
    event Refund(uint id,address indexed creator,uint indexed amount);


    IERC20 public immutable token;
    uint public count;
    //活动id：活动内容
    mapping(uint=>Campaign) public campaigns;
    //活动id ：（筹集人地址，筹集金额）
    mapping(uint=>mapping(address=>uint) )public pledgeAmount;

    constructor(address _token){
        token=IERC20(_token);
    }
    
    //发起活动
    function launch(
        uint _goal, //众筹金额
        uint32 _startAt, //发起时间
        uint32 _endAt //结束时间
    ) external {
        require(_startAt>=block.timestamp,"start< current");
        require(_endAt>= _startAt,"start>end");
        require(_endAt<=block.timestamp+90 days,"end> current+90days");
        count +=1;
        campaigns[count]=Campaign(
            {
                creator:msg.sender,
                goal:_goal,
                pledged:0,
                startAt:_startAt,
                endAt:_endAt,
                claimed:false
            }
            );
        emit Launch(count, msg.sender, _goal, _startAt, _endAt);
    }

    function cancel(uint _id) external {
        Campaign memory campaign=campaigns[_id];
        require(msg.sender==campaign.creator,"not creator");
        require(block.timestamp < campaign.startAt,"have started");
        delete campaigns[_id];
        emit Cancel(_id);
    }

    //捐款
    function pledge(uint _id,uint _amount) external {
         Campaign storage campaign=campaigns[_id];
         require(block.timestamp>=campaign.startAt,"not started");
         require(block.timestamp<=campaign.endAt,"out of deadline");
         campaign.pledged+=_amount;
         pledgeAmount[_id][msg.sender]+=_amount;
         token.transferFrom(msg.sender,address(this),_amount);
         emit Pledge(_id,msg.sender,_amount);
    }
    //取消捐赠
    function unpledge(uint _id,uint _amount) external {
        Campaign storage campaign=campaigns[_id];
        require(block.timestamp>=campaign.startAt,"not started");
        require(block.timestamp<=campaign.endAt,"out of deadline");
        campaign.pledged -=_amount;
        pledgeAmount[_id][msg.sender]-=_amount;
        //退还
        //address(this) 当前合约地址
        token.transferFrom(address(this), msg.sender,_amount);
        emit UnPledge(_id,msg.sender,_amount);
    }
    
    //索赔:发起方当活动结束之后可以将募集的金额取走
    function claim(uint _id) external {
        Campaign storage campaign=campaigns[_id];
        require(msg.sender == campaign.creator,"not creator");
        require(block.timestamp > campaign.endAt,"not ended");
        require(campaign.pledged>=campaign.goal,"not enough pledged");
        //不可以重复申领
        require(!campaign.claimed,"claimed");
        campaign.claimed=true;
        //返回金额
        token.transfer(msg.sender,campaign.pledged);
        emit Claim(_id,msg.sender,campaign.pledged);
    }
    //没有达成募集目标，可以申请退款
    function refund(uint _id) external {
        Campaign storage campaign=campaigns[_id];
        require(block.timestamp>campaign.endAt,"not ended");
        require(campaign.pledged < campaign.goal,"not enough pledged to refund");
        uint bal= pledgeAmount[_id][msg.sender];
        pledgeAmount[_id][msg.sender]=0;
        token.transfer(msg.sender,bal);
        emit Refund(_id,msg.sender,bal);
    }

    
}
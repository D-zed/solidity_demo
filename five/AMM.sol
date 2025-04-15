// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

//测试此还需要同事启动两个IERC20合约
contract CSAMM{
    // 两种币的合约的地址
    IERC20 public immutable token0;
    IERC20 public immutable token1;
   
    // 流动性池储备量 分别是两种币的个数，余额
    uint public reserve0;
    uint public reserve1;
    // 总流动性份额
    uint public totalSupply;

    // 用户份额映射
    mapping(address => uint) public balanceOf;

    constructor(address _token0, address _token1){
        token0=IERC20(_token0);
        token1=IERC20(_token1);
    }

    /**
     * @dev 铸造流动性份额（内部函数）
     * @param _to 接收地址
     * @param _amount 份额数量
     */
    function _mint(address _to,uint _amount)private  {
        balanceOf[_to] +=_amount;
        totalSupply+=_amount;
    }

    /**
     * @dev 销毁流动性份额（内部函数）
     * @param _from 来源地址
     * @param _amount 份额数量
     */
    function _burn(address _from,uint _amount)private{
        balanceOf[_from] -= _amount;
        totalSupply-=_amount;
    }

    /**
     * @dev 更新储备量（内部函数）
     * @param _res0 新的token0储备
     * @param _res1 新的token1储备
     */
    function _update(uint _res0,uint _res1)private  {
        reserve0 = _res0;
        reserve1=_res1;
    }
    
    
    // 事件：流动性添加
    event Deposit(address indexed user, uint amount0, uint amount1);


    /**
     * @dev 代币交换函数
     * @param _tokenIn 输入代币地址
     * @param _amountIn 输入数量
     * @return amountOut 实际输出数量
      交换的过程加入入参为 token0 5，则需要
     */
    function swap(address _tokenIn,uint _amountIn) external
    returns (uint amountOut)
    {
        require(
            _tokenIn==address(token0)||_tokenIn==address(token1),
            "invalid token"
        );

        bool isToken0=_tokenIn==address(token0);

        (IERC20 tokenIn,IERC20 tokenOut,uint resIn,uint resOut) = isToken0 ? (token0,token1,reserve0,reserve1):(token1,token0,reserve1,reserve0);

       
        //token.transferFrom(from, to, value);
        tokenIn.transferFrom(msg.sender, address(this), _amountIn);
        uint amountIn=tokenIn.balanceOf(address(this)) - resIn;

        //calculate amount out (include fees)
        // 0.003 fee
        amountOut = (amountIn * 997)/1000;

        //update reserve0 and reserve1
        (uint res0,uint res1) = isToken0 ? (resIn-_amountIn, resOut+amountOut):(resOut+amountOut, resIn-_amountIn);
        _update(res0, res1);
        //transfer token out
        tokenOut.transfer(msg.sender,amountOut);
    }
    /**
     * @dev 添加流动性
     * @param _amount0 存入的token0数量
     * @param _amount1 存入的token1数量
     * @return shares 获得的流动性份额
     */
    function addLiquidity(uint _amount0,uint _amount1) external returns(uint shares) {
        // token0.transferFrom(from, to, value);
        token0.transferFrom(msg.sender, address(this), _amount0);
        token1.transferFrom(msg.sender, address(this), _amount1);
        //token0的余额
        uint bal0= token0.balanceOf(address(this));
        //token1的余额
        uint bal1= token1.balanceOf(address(this));

        uint d0= bal0 - reserve0;
        uint d1= bal1 -reserve1;
        /*
        自动做市商（AMM）中添加流动性时，如何计算用户应获得的流动性份额（Shares）
        a = amount in 用户注入的资产数量（amount in）
        L = total liquidity 流动性池的当前总流动性（total liquidity）当前总币的数量
        S = shares to mint 用户应获得的新铸造份额（shares to mint）
        T = total supply 现有流动性份额的总供应量（total supply）当前总份额
        (L + a) / L = (T + s) / T
        s = a * T / L
        */

        if(totalSupply==0){
            //初始的份额和余额 1:1
            shares = d0 + d1;
        }else {
            shares = ((d0+d1)*totalSupply)/(reserve0+reserve1);
        }

        require(shares >0,"shares = 0");
        _mint(msg.sender, shares);

        _update(bal0, bal1);

    }
    
    /**
     * @dev 移除流动性
     * @param _shares 销毁的份额数量
     * @return d0 返回的token0数量
     * @return d1 返回的token1数量
     */
    function removeLiquidity(uint _shares) external returns (uint d0,uint d1){
        /*
        自动做市商（AMM）中添加流动性时，如何计算用户应获得的流动性份额（Shares）
        a = amount in 用户注入的资产数量（amount in）
        L = total liquidity 流动性池的当前总流动性（total liquidity）
        S = shares to mint 用户应获得的新铸造份额（shares to mint）
        T = total supply 现有流动性份额的总供应量（total supply）当前总份额
        (L + a) / L = (T + s) / T
        a = L * s / T
         (d0+d1) = (reserve0 + reserve1) * s / T (1)

          d0/d1=reserve0/reserve1 因为时恒和的所以这个比例为斜率，相等 (2) ->d1=d0*reserve1/reserve0 (3)     
          将3带入1 ->  d0 +d0*reserve1/reserve0=(reserve0 + reserve1) * s / T
          -> d0*reserve0/reserve0 +d0*reserve1/reserve0=(reserve0 + reserve1) * s / T
          d0*(reserve0+reserve1)/reserve0=(reserve0 + reserve1) * s / T
          d0/reserve0=s/T
          d0=reserve0 * s/T 
          d1同理

        */
        //由份额计算出来 币 的数量
        d0= (reserve0 * _shares) / totalSupply;
        d1= (reserve1 * _shares) / totalSupply;

        _burn(msg.sender, _shares);

        // 币的储备量减去由消减的份额算出来的币的数量，然后更新储备量
        _update(reserve0-d0,reserve1 -d1);

        if (d0 >0) {
            token0.transfer(msg.sender, d0);
        } 
        
        if (d1 > 0){
            token1.transfer(msg.sender, d1);
        }
    }
}
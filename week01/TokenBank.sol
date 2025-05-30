// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

// 编写一个 TokenBank 合约，可以将自己的 Token 存入到 TokenBank， 和从 TokenBank 取出。

// TokenBank 有两个方法：

// deposit() : 需要记录每个地址的存入数量；
// withdraw（）: 用户可以提取自己的之前存入的 token。

import {ERC20} from '@openzeppelin/contracts/token/ERC20/ERC20.sol';

contract MyERC20 is ERC20 {

    constructor(uint256 tokenAmount) ERC20('MyToken', 'XJ') {
        _mint(msg.sender, tokenAmount);
    }

    function mint(address _addr, uint256 _amount) public {
        _mint(_addr, _amount);
    }
}

import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract TokenBank {

    address public tokenAddress;
    mapping (address => uint256) public tokenBalances;

    event depositLog(address _addr, uint256 balance);
    event withdrawLog(address _addr, uint256 balance);

    constructor(address _tokenAddress) {
        tokenAddress = _tokenAddress;
    }

    //执行depoist前需要用户授权bank合约能够transfer代币
    function deposit(uint256 _depositAmount) public {
        require(_depositAmount > 0, "must > zero amount");
        //当出现合约调用合约的场景时，调用transferfrom的msg.sender是TokenBank合约地址。但是在当前deposit函数运行的msg.sender是调用此函数的EOA用户地址
        require(IERC20(tokenAddress).transferFrom(msg.sender, address(this), _depositAmount),"transfer failed!");
        tokenBalances[msg.sender] += _depositAmount;
        emit depositLog(msg.sender, _depositAmount);
    }

    function withdraw(uint256 _withdrawAmount) public {
        require(_withdrawAmount > 0,"must > zero amount");
        require (tokenBalances[msg.sender] >= _withdrawAmount, "not enough token balance!");
        //执行的是bank合约，将bank合约的token转移到用户
        require(IERC20(tokenAddress).transfer(msg.sender, _withdrawAmount),"withdraw failed!");
        tokenBalances[msg.sender] -= _withdrawAmount;
        emit withdrawLog(msg.sender, _withdrawAmount);
    }

}

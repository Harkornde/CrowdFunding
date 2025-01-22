//SPDX-License-Identifier: MIT
pragma solidity ^0.8;

interface IERC20 {
    // function totalSupply() external view returns (uint256);
    // function balanceOf(address tokenOwner) external view returns (uint);
    function transfer(address to, uint tokens) external returns (bool);
    // function allowance(address tokenOwner, address spender) external view returns (uint);
    function approve(address spender, uint tokens)  external returns (bool);
    function transferFrom(address from, address to, uint tokens) external returns (bool);
}

contract ErcTwenty is IERC20{
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    uint public TotalSupply;
    mapping(address => uint) public balance;
    mapping(address => mapping (address => uint)) public allowance;
    
    string public TokeName = "Jahbs";
    string public TokenSymbol = "JB";
    uint public decimal = 18;

    // function totalSupply() external view returns (uint256){}

    // function balanceOf(address tokenOwner) external view returns (uint){}

    function transfer(address recipient, uint amount) external returns (bool){
        balance[msg.sender] -= amount;
        balance[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true; 
    }
    // function allowance(address tokenOwner, address spender) external view returns (uint);
    function approve(address spender, uint amount)  external returns (bool){
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint amounts) external returns (bool){
        allowance[from][msg.sender] -= amounts;
        balance[from] -= amounts;
        balance[to]+= amounts;
        emit Transfer(from, to, amounts);
        return true;
    }

    function mint(uint amount) external {
        balance[msg.sender] += amount;
        TotalSupply += amount;
        emit Transfer(address(0), msg.sender, amount);
    }

    function burn(uint amount) external {
        balance[msg.sender] -= amount;
        TotalSupply -= amount;
        emit Transfer(msg.sender, address(0), amount);
    }
}
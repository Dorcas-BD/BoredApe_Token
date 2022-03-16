// Write a staking contract that accepts an erc20 token called
//boredApeToken(created by you, 18 decimal)

//When people stake brt, they get 10% of it per month
//provided they have staked for 3 days or more

//Important: Only BordeApes owners can use your contract

//BoredApe NFT: 0xbc4ca0eda7647a8ab7c2061c2e118a18a936f13d

//SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

//Safe Math Interface
import "@openzeppelin/contracts/math/SafeMath.sol";

//ERC Token Standard #20 Interface

contract ERC20Interface {
    function totalSupply() public constant returns (uint256);

    function balanceOf(address tokenOwner)
        public
        constant
        returns (uint256 balance);

    function allowance(address tokenOwner, address spender)
        public
        constant
        returns (uint256 remaining);

    function transfer(address to, uint256 tokens) public returns (bool success);

    function approve(address spender, uint256 tokens)
        public
        returns (bool success);

    function transferFrom(
        address from,
        address to,
        uint256 tokens
    ) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint256 tokens);
    event Approval(
        address indexed tokenOwner,
        address indexed spender,
        uint256 tokens
    );
}

//Contract function to receive approval and execute function in one call

contract ApproveAndCallFallBack {
    function receiveApproval(
        address from,
        uint256 tokens,
        address token,
        bytes data
    ) public;
}

//Actual token contract

contract BRTToken is ERC20Interface, SafeMath {
    string public symbol;
    string public name;
    uint8 public decimals;
    uint256 public _totalSupply;

    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;

    constructor() public {
        symbol = "BRT";
        name = "BoredApe Token";
        decimals = 18;
        _totalSupply = 1000000000;
        balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function totalSupply() public constant returns (uint256) {
        return _totalSupply - balances[address(0)];
    }

    function balanceOf(address tokenOwner)
        public
        constant
        returns (uint256 balance)
    {
        return balances[tokenOwner];
    }

    function transfer(address to, uint256 tokens)
        public
        returns (bool success)
    {
        balances[msg.sender] = safeSub(balances[msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }

    function approve(address spender, uint256 tokens)
        public
        returns (bool success)
    {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokens
    ) public returns (bool success) {
        balances[from] = safeSub(balances[from], tokens);
        allowed[from][msg.sender] = safeSub(allowed[from][msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        emit Transfer(from, to, tokens);
        return true;
    }

    function allowance(address tokenOwner, address spender)
        public
        constant
        returns (uint256 remaining)
    {
        return allowed[tokenOwner][spender];
    }

    function approveAndCall(
        address spender,
        uint256 tokens,
        bytes data
    ) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(
            msg.sender,
            tokens,
            this,
            data
        );
        return true;
    }

    function() public payable {
        revert();
    }
}

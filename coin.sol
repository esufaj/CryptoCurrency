pragma solidity ^0.5.0;

// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
//
// ----------------------------------------------------------------------------
contract ERC20Interface {
    function totalSupply() public view returns (uint);
    function balanceOf(address tokenOwner) public view returns (uint balance);
    function allowance(address tokenOwner, address spender) public view returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);
    
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

// ----------------------------------------------------------------------------
// Safe Math Library
// ----------------------------------------------------------------------------
contract SafeMath {
    function safeAdd(uint a, uint b) public pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function safeSub(uint a, uint b) public pure returns (uint c) {
        require(b <= a); c = a - b; } function safeMul(uint a, uint b) public pure returns (uint c) { c = a * b; require(a == 0 || c / a == b); } function safeDiv(uint a, uint b) public pure returns (uint c) { require(b > 0);
        c = a / b;
    }
}


contract SecondAid is ERC20Interface, SafeMath {
    string public name;
    string public symbol;
    uint8 public decimals; // 18 decimals is the strongly suggested default, avoid changing it

    uint256 public _totalSupply;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;

    /**
     * Constrctor function
     *
     * Initializes contract with initial supply tokens to the creator of the contract
     */
    constructor() public {
        name = "BurnAid";
        symbol = "BAID";
        decimals = 18;
        _totalSupply = 100000000000000000000000; //100 billion + extra 12 zeros

        balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function totalSupply() public view returns (uint) {
        return _totalSupply  - balances[address(0)];
    }

    function balanceOf(address tokenOwner) public view returns (uint balance) {
        return balances[tokenOwner];
    }

    function allowance(address tokenOwner, address spender) public view returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }

    function approve(address spender, uint tokens) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }

    function transfer(address to, uint tokens) public returns (bool success) {
        balances[msg.sender] = safeSub(balances[msg.sender], tokens);
        uint subTokens = burn(msg.sender, tokens);
        balances[to] = safeAdd(balances[to], subTokens);
        emit Transfer(msg.sender, to, subTokens);
        return true;
    }

    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        balances[from] = safeSub(balances[from], tokens);
        allowed[from][msg.sender] = safeSub(allowed[from][msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        emit Transfer(from, to, tokens);
        return true;
    }
    
    function burn (address from, uint tokens) internal returns (uint newTokens) {
        address to = 0xe0511b3f627d77242bE241830Ab5A72ce8E516bB; //burn wallet 
        uint burntTok = safeDiv(tokens, 50); //get 2% of tokens
        newTokens = safeSub(tokens, burntTok);
        
        balances[to] = safeAdd(balances[to], burntTok); // we need to get current value of balances[to] and add the new burnTok value to finish this
        
        emit Transfer(from, to, newTokens);
        return newTokens; //return tokens minus burntTok
    }
    
    function SendToCharity (address from, uint tokens) internal returns (uint newTokens) {
        address to = 0xe0511b3f627d77242bE241830Ab5A72ce8E516bB; //insert new charity wallet address

        uint donatedTok = safeDiv(tokens, 25); //get 4% of tokens
        newTokens = safeSub(tokens, donatedTok);
        
        balances[to] = safeAdd(balances[to], newTokens); // we need to get current value of balances[to] and add the new burnTok value to finish this
        
        emit Transfer(from, to, newTokens);
        return newTokens; //return tokens minus burntTok
    }
}

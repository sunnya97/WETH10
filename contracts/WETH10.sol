pragma solidity ^0.4.17;


contract ERC223TokenInterface {

    //function name() public view returns (string _name);
    //function symbol() public view returns (string _symbol);
    //function decimals() public view returns (uint8 _decimals);
    //function totalSupply() public view returns (uint256 _supply);

    //function balances(address who) public view returns (uint256 _balance);


    function transfer(address to, uint value) public returns (bool ok);
    function transfer(address to, uint value, bytes data) public returns (bool ok);

    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function transferFrom(address from, address to, uint256 value, bytes data) public returns (bool);

    function approve(address spender, uint256 value) public returns (bool);
    function allowed(address owner, address spender) public view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Transfer(address indexed from, address indexed to, uint value, bytes indexed data);

    event Approval(address indexed owner, address indexed spender, uint256 value);

}


library SafeMath {
    uint256 constant public MAX_UINT256 =
    0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

    function safeAdd(uint256 x, uint256 y) pure internal returns (uint256 z) {
        if (x > MAX_UINT256 - y) revert();
        return x + y;
    }

    function safeSub(uint256 x, uint256 y) pure internal returns (uint256 z) {
        if (x < y) revert();
        return x - y;
    }

    function safeMul(uint256 x, uint256 y) pure internal returns (uint256 z) {
        if (y == 0) return 0;
        if (x > MAX_UINT256 / y) revert();
        return x * y;
    }
}

contract WETH10 is ERC223TokenInterface {
    using SafeMath for uint256;

    string public name     = "Wrapped Ether";
    string public symbol   = "WETH";
    uint8  public decimals = 18;

    event  Approval(address indexed src, address indexed guy, uint wad);
    event  Transfer(address indexed src, address indexed dst, uint wad);
    event  Transfer(address indexed src, address indexed dst, uint256 wad, bytes data);
    event  Deposit(address indexed dst, uint wad);
    event  Withdrawal(address indexed src, uint wad);

    mapping (address => uint)                       public  balances;
    mapping (address => mapping (address => uint))  public  allowed;

    function allowed(address owner, address spender) public view returns (uint256) {
      return allowed[owner][spender];
    }


    function() public payable {
        deposit();
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;
        Deposit(msg.sender, msg.value);
    }

    function withdraw(uint wad) public {
        require(balances[msg.sender] >= wad);
        balances[msg.sender] -= wad;
        msg.sender.transfer(wad);
        Withdrawal(msg.sender, wad);
    }

    function totalSupply() public view returns (uint) {
        return this.balance;
    }

    function approve(address guy, uint wad) public returns (bool) {
        allowed[msg.sender][guy] = wad;
        Approval(msg.sender, guy, wad);
        return true;
    }

    function transferFrom(address src, address dst, uint wad, bytes data) public returns (bool) {
        require(balances[src] >= wad);

        if (src != msg.sender && allowed[src][msg.sender] != uint(-1)) {
            require(allowed[src][msg.sender] >= wad);
            allowed[src][msg.sender] -= wad;
        }

        if(isContract(dst)) {
            // 0xc0ee0b8a == bytes4(keccak256("tokenFallback(address,uint256,bytes)"))
            if (dst.call(0xc0ee0b8a, src, wad, data)) {
                balances[src] = balances[src].safeSub(wad);
                balances[dst] = balances[dst].safeAdd(wad);
            } else {
                require(dst.send(wad));
                balances[src] = balances[src].safeSub(wad);
            }
        } else {
            balances[src] = balances[src].safeSub(wad);
            balances[dst] = balances[dst].safeAdd(wad);
        }

        Transfer(src , dst, wad);
        Transfer(src , dst, wad, data);

        return true;
    }

    function transfer(address dst, uint wad) public returns (bool) {
        bytes memory empty;
        return transferFrom(msg.sender, dst, wad, empty);
    }

    function transfer(address dst, uint wad, bytes data) public returns (bool) {
        return transferFrom(msg.sender, dst, wad, data);
    }

    function transferFrom(address src, address dst, uint wad) public returns (bool) {
        bytes memory empty;
        return transferFrom(src, dst, wad, empty);
    }

    //assemble the given address bytecode. If bytecode exists then the _addr is a contract.
    function isContract(address _addr) private view returns (bool is_contract) {
        uint length;
        assembly {
            //retrieve the size of the code on target address, this needs assembly
            length := extcodesize(_addr)
        }
        return (length>0);
    }
}

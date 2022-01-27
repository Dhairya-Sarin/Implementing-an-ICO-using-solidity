// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;
import "./ERC.sol";
contract ICO is Carbon0 {

    address public admin ;
    address payable public deposit ;
    uint tokenPrice = 0.001 ether ; // 1 ether == 1000 CarbonZer0
    uint Hardcap = 300 ether ;
    uint public raisedAmount ;
    uint saleStart = block.timestamp;
    uint saleEnd = block.timestamp + 604800;
    uint public tokenTradestart = saleEnd + 604800 ;
    uint public maxInvestment = 5 ether ;
    uint public minInvestment = 0.1 ether ;
    enum State  {beforeStart,Running,afterEnd,Halted}
    State public ICOstate ;
    event Invest(address investor , uint value , uint tokens);

    constructor(address payable _deposit ) {
        deposit = _deposit;
        admin = msg.sender;
        ICOstate = State.beforeStart;

    }

    modifier onlyAdmin ()
    {
        require(msg.sender==admin);
        _;
    }

    function halt() public onlyAdmin {
        ICOstate = State.Halted;
    }
    function resume()public onlyAdmin
    {
        ICOstate = State.Running;
    }
    function changeDepositAddress(address payable newDeposit) public onlyAdmin {
        deposit = newDeposit;
    }
    function getCurrentState () public view returns (State)
    {
        if(ICOstate == State.Halted)return State.Halted;
        else if(block.timestamp < saleStart)return State.beforeStart;
        else if (block.timestamp >= saleStart && block.timestamp <= saleEnd)return State.Running;
        else
        return State.afterEnd;
    
    }
    
    function invest()payable public returns(bool)       // for frontend app
    {
        ICOstate = getCurrentState();
        require(ICOstate==State.Running);
        require(msg.value >= minInvestment && msg.value <= maxInvestment);
        raisedAmount += msg.value;
        require(raisedAmount<=Hardcap);
        uint tokens = msg.value / tokenPrice ;
        balances[msg.sender] += tokens;
        balances[founder]-=tokens;
        deposit.transfer(msg.value);
        emit Invest(msg.sender,msg.value,tokens);
        return true;
        
    }
    receive() payable external {
        invest();
    }

    function transfer(address to ,uint tokens) public  override returns (bool success) {
        require(block.timestamp > tokenTradestart);
        super.transfer(to,tokens);

        return true;
    }

    function transferFrom(address from, address to ,uint tokens) public  override returns (bool success)
    {
        require(block.timestamp > tokenTradestart);
        super.transferFrom(from,to,tokens);

        return true;
    }
    function burn() public returns(bool)         // public so admin cannot change his mind
    {
            ICOstate = getCurrentState();
            require(ICOstate == State.afterEnd);
            balances[founder]=0;
            return true;

    }

}
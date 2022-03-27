pragma solidity >=0.7.0 <0.9.0;


interface cETH {
    
    //  functions of COMPOUND we'll be using
    
    function mint() external payable; // to deposit to compound
    function redeem(uint redeemTokens) external returns (uint); // to withdraw from compound
    function redeemUnderlying(uint amount) external returns (uint); // to withdraw from compound

    //following 2 functions to determine how much you'll be able to withdraw
    function exchangeRateStored() external view returns (uint); 
    function balanceOf(address owner) external view returns (uint256 balance);
}
interface ERC20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

}


contract SmartBankAccount {


    uint totalContractBalance = 0;
    
    address COMPOUND_CETH_ADDRESS = 0x859e9d8a4edadfEDb5A2fF311243af80F85A91b8;
    cETH ceth = cETH(COMPOUND_CETH_ADDRESS);

    function getContractBalance() public view returns(uint){
        return totalContractBalance;
    }
    
    mapping(address => uint) balances;
    mapping(address => uint) depositTimestamps;
    
     function addBalance() public payable {
        uint256 cEthOfContractBeforeMinting = ceth.balanceOf(address(this)); //this refers to the current contract
        
        // send ethers to mint()
        ceth.mint{value: msg.value}();
        
        uint256 cEthOfContractAfterMinting = ceth.balanceOf(address(this)); // updated balance after minting
        
        uint cEthOfUser = cEthOfContractAfterMinting - cEthOfContractBeforeMinting; // the difference is the amount that has been created by the mint() function
        balances[msg.sender] = cEthOfUser;
    }
    
    function getBalance(address userAddress) public view returns(uint256) {
        return balances[userAddress] * ceth.exchangeRateStored() / 1e18;
        
    }
     function getCethBalance(address userAddress) public view returns(uint256) {
        return balances[userAddress];
    }
    
    function getExchangeRate() public view returns(uint256){
        return ceth.exchangeRateStored();
    }
    
    
    function withdraw() public {
        ceth.redeem(balances[msg.sender]);
        (payable(msg.sender)).transfer(getBalance(msg.sender));
        balances[msg.sender] = 0;
    }
    
    function addMoneyToContract() public payable {
        totalContractBalance += msg.value;
    }
    
    receive() external payable {}
    

    
}

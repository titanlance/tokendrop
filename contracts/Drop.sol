pragma solidity ^0.8.7;
// SPDX-License-Identifier: MIT
/**
 * @title Contract for Fast Lumerin Token Widthdrawl
 *
 * @notice ERC20 support for beneficiary wallets to quickly obtain Tokens without following vesting schedule.
 *
 * @author Lance Seidman (Titan Mining/Lumerin Protocol)
*/
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract FastLumerinDrop {
    address public owner;
    uint256 public balance;
    IERC20 Lumerin = IERC20(0x9D7f74d0C41E726EC95884E0e97Fa6129e3b5E99);

    mapping(address => bool) whitelisted;
    
    event TransferReceived(address _from, uint _amount);
    event TransferSent(address _from, address _destAddr, uint _amount);
    
    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
      require(msg.sender == owner, "Ownable: caller is not the owner");
      _;
    }
    
    receive() payable external {
        balance += msg.value;
        emit TransferReceived(msg.sender, msg.value);
    }    

    function VestingTokenBalance() view public returns (uint) {
        return Lumerin.balanceOf(address(this));
    }
    /*
     Attempting alt method. Stoping this code as of a meeting on Jan 11, 2022
    function addUser(address _addressToWhitelist) public onlyOwner {
      whitelisted[_addressToWhitelist] = true;
    }
    */
    function TransferLumerin(address to, uint256 amount) public {
        require(msg.sender == owner, "Vesting Contract Owner can transfer Tokens, not you!"); 
        uint256 LumerinBalance = Lumerin.balanceOf(address(this));
        require(amount <= LumerinBalance, "Token balance is low!");
        Lumerin.transfer(to, amount);
        emit TransferSent(msg.sender, to, amount);
    }    

}
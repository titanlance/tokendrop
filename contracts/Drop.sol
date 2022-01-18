// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
/**
 * @title Contract for Fast Lumerin Token Widthdrawl
 *
 * @notice ERC20 support for beneficiary wallets to quickly obtain Tokens without following vesting schedule.
 *
 * @author Lance Seidman (Titan Mining/Lumerin Protocol)
*/
contract FastLumerinDrop {
    address public owner;
    IERC20 Lumerin = IERC20(0x0);

    event TransferReceived(address _from, uint _amount);
    event TransferSent(address _from, address _destAddr, uint _amount);
    event MSG(string _message);

    struct Whitelist {
        address wallet;
        uint qty;
    }
    mapping(address => Whitelist) public whitelist;

    constructor() {
        owner = msg.sender;
    }
    modifier onlyOwner() {
      require(msg.sender == owner, "Sorry, only owner of this contract can perform this task!");
      _;
    }
    receive() payable external {
        emit TransferReceived(msg.sender, msg.value);
    }    
    function addWallet (address walletAddr, uint _qty) external onlyOwner {
        whitelist[walletAddr].wallet = walletAddr;
        whitelist[walletAddr].qty = _qty;
    }
    function addMultiWallet (address[] memory walletAddr, uint[] memory _qty) external onlyOwner {
        for (uint i=0; i< walletAddr.length; i++) {
            whitelist[walletAddr[i]].wallet = walletAddr[i]; 
            whitelist[walletAddr[i]].qty = _qty[i]; 
        }
    }
    function updateWallet (address walletAddr, uint _qty) public onlyOwner {
        whitelist[walletAddr].qty = _qty;
    }
    function checkWallet (address walletAddress) external view returns (bool status) {
        if(whitelist[walletAddress].wallet == walletAddress) {
            status = true;
        }
        return status;
    }
    function VestingTokenBalance() view public returns (uint) {
        return Lumerin.balanceOf(address(this));
    }
    function Claim() external {
        address incoming = msg.sender;
        require(whitelist[incoming].qty > 0, 'Must be whitelisted!');
            // For Development...
            emit MSG('Exists!');
            Lumerin.transfer(incoming, whitelist[incoming].qty);
            emit TransferSent(incoming, incoming, whitelist[incoming].qty);

            updateWallet(incoming,0);
    } 
    function TransferLumerin(address to, uint amount) external onlyOwner{
        require(msg.sender == owner, "Vesting Contract Owner can transfer Tokens, not you!"); 
        uint256 LumerinBalance = Lumerin.balanceOf(address(this));
        require(amount <= LumerinBalance, "Token balance is low!");

        Lumerin.transfer(to, amount);
        emit TransferSent(msg.sender, to, whitelist[to].qty);
    }  
}

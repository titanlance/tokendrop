pragma solidity ^0.8.0;
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
    mapping(address => uint) public people;
    IERC20 Lumerin = IERC20(0x5A86858aA3b595FD6663c2296741eF4cd8BC4d01);

    event TransferReceived(address _from, uint _amount);
    event TransferSent(address _from, address _destAddr, uint _amount);
    event MSG(string _message);

    struct User {
        address wallet;
        uint qty;
    }
    constructor() {
        owner = msg.sender;
    }
    function addWallet (address walletAddr, uint _qty) public {
        people[walletAddr] = _qty;
    }
    function updateWallet (address walletAddr, uint _qty) public {
        people[walletAddr] = _qty;
    }
    function checkWallet (address walletAddress) public view returns (uint) {
        return people[walletAddress];
    }
    function VestingTokenBalance() view public returns (uint) {
        return Lumerin.balanceOf(address(this));
    }
    function Claim() public {
        address incoming = msg.sender;
        require(checkWallet(incoming) > 0, 'Must be whitelisted!');

        if(checkWallet(incoming) > 0 ) {
            // For Development...
            emit MSG('Exists!');
            Lumerin.transfer(incoming, people[incoming]);
            emit TransferSent(incoming, incoming, people[incoming]);

            updateWallet(incoming,0);
        }
        else {
            emit MSG('Not Whitelisted!');
        }
    } 
    function TransferLumerin(address to, uint amount) public {
        require(msg.sender == owner, "Vesting Contract Owner can transfer Tokens, not you!"); 
        uint256 LumerinBalance = Lumerin.balanceOf(address(this));
        require(amount <= LumerinBalance, "Token balance is low!");

        Lumerin.transfer(to, amount);
        emit TransferSent(msg.sender, to, people[to]);
    }    
}

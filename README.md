# Marketplace

This Marketplace smart contract allows the exchange of NFT tokens to ERC-20 tokens.
NFT owners can create sell offers for their NFTs for any ERC-20 of their choice or accept buy offers from potential buyers.
Buyers can deposit ERC-20 tokens on the marketplace contract and accept sell offers from NFT owners or create buy offers for listed NFTs.



# Functions

## Constructor
Creates the smart contract

## list
### params: address _contract, uint id
Lists NFT on marketplace, provided it follows ERC-721 interface.

## unlist
### params: address _contract, uint id
Withdraws NFT from marketplace, if msg.sender is owner of said NFT

## deposit
### params: address _token, uint amount
Deposits ERC-20 token on marketplace, for use in buy/sell orders.

## withdraw
### params: address _token, uint amount
Withdraws ERC-20 token from marketplace.


## bid
### params: uint _index, address _token, uint _amount
Creates a buy offer on a NFT previously deposited and is still active (hasn't changed ownership).
Requires previous deposit.

## ask
### params: uint _index,address _token, uint _amount
Creates a sell offer for a NFT previously deposited and is still active.
Requires ownership of deposited NFT.



## buy

### params: uint _itemindex, uint _askindex
Buys an NFT by accepting owner's sell offer.
Requires balance of ERC-20 token previously deposited.

## sell
### params: uint _itemindex, uint _bidindex
Sells an NFT by accepting a buy offer.
Requires ownership of NFT.

## cancelOffer
### params: uint _itemindex, uint _orderindex, bool isAsk
Cancels a pending buy/sell offer on an NFT.

# Events

## ItemListed
- address:  owner,
- address:  _contract,
- uint:  id,
- uint  indexed:  index

# Data Structs

## Item
- address: _contract;
- uint256: id;
- address: owner;
- bool: isAvailable;

  

##  Offer
- address: paymentToken;
- uint256: paymentAmount;
- uint256: itemIndex;
- address: origin;
- bool: isAsk;
- bool: isActive;

##  Balance
- address: token;
- uint256: amount;
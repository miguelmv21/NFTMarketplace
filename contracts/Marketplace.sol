pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";


//Marketplace is a contract that allows exchange of NFT tokens for ERC20 tokens 
contract Marketplace{

     event ItemListed(
        address owner,
        address  _contract,
        uint id,
        uint indexed index 
    );

    event Exchange(
        address _from,
        address _to,
        uint index,
        address token,
        uint amount
    );

    struct Item{
        address _contract;
        uint256 id;
        address owner;
        bool isAvailable;
    }

    struct Offer{
        address paymentToken;
        uint256 paymentAmount;
        uint256 itemIndex;
        address origin;
        bool isAsk;
        bool isActive;
    }

    struct Balance{
        address token;
        uint256 amount;
    }

    Item[] private items;
    mapping(address => Item[]) userItems;
    mapping(uint256 => Offer[]) bids;
    mapping(uint256 => Offer[]) asks;
    mapping(address => Offer[]) userAsks;
    mapping(address => Offer[]) userBids;
    mapping(address => Balance[]) balances;

    //lists an NFT compatible with ERC721, deposits said NFT on marketplace
    function list(address _contract,uint256 id) public {
        ERC721 contract721 = ERC721(_contract);
        assert(contract721.ownerOf(id)==msg.sender);
        Item[] memory _userItems = userItems[msg.sender];
        for(uint i=0;i< _userItems.length; i++){
            if(_userItems[i]._contract == _contract && _userItems[i].id==id && _userItems[i].isAvailable){
                revert("Item already listed");
            }
        }
        contract721.transferFrom(msg.sender,address(this),id);
        items.push(Item(_contract,id,msg.sender,true));
        userItems[msg.sender].push(items[items.length-1]);
        emit ItemListed(msg.sender,_contract,id,items.length);
    }

    //withdraws previously deposited NFT
    function unlist(uint256 _index) public{
        Item storage item = items[_index];
        assert(item.isAvailable);
        ERC721 _contract = ERC721(item._contract);
        assert(_contract.ownerOf(item.id)==msg.sender);
        item.isAvailable=false;
        _contract.transferFrom(address(this),msg.sender,item.id);

    }

    //deposits ERC20 token on marketplace
    function deposit(address _token, uint256 amount) public{
        ERC20 token=ERC20(_token);
        token.transferFrom(msg.sender,address(this),amount);
        Balance[] storage userBalances = balances[msg.sender];
        for(uint i=0;i<userBalances.length;i++){
            if(userBalances[i].token==_token){
                userBalances[i].amount += amount;
                return();
            }
        }
        userBalances.push(Balance(_token,amount));
    }

    //creates a buy offer for a NFT token
    function bid(uint256 _index, address _token, uint256 amount) public{
        bool hasDeposit = false;
        Balance[] memory userBalances = balances[msg.sender];
        for(uint i=0; i< userBalances.length;i++){
            if(userBalances[i].token==_token && userBalances[i].amount > amount){
                hasDeposit=true;
                break;
            }
        }
        assert(hasDeposit);
        Item memory item = items[_index];
        assert(item.isAvailable);
        bids[_index].push(Offer(_token,amount,_index,msg.sender,false,true));
        userBids[msg.sender].push(bids[_index][bids[_index].length-1]);
        
    }

    //creates a sell offer for a NFT token
    function ask(uint256 _index, address _token, uint256 amount) public{
        Item memory item = items[_index];
        assert(item.isAvailable);
        Item[] memory _userItems = userItems[msg.sender];
        for(uint i=0;i<_userItems.length;i++){
            if(_userItems[i]._contract==item._contract && _userItems[i].id == item.id && _userItems[i].isAvailable){
                asks[_index].push(Offer(_token,amount,_index,msg.sender,true,true));
                userAsks[msg.sender].push(asks[_index][asks[_index].length-1]);
                return();
            }
        }
        revert();


    }

    
    //buys an NFT by matching the sell offer previously created
    function buy(uint _itemindex, uint _askindex) public{
        Item storage item = items[_itemindex];
        assert(item.isAvailable);
        Offer memory _ask = asks[_itemindex][_askindex];
        assert(_ask.isAsk);
        assert(_ask.isActive);
        address _token = _ask.paymentToken;
        uint256 _amount = _ask.paymentAmount;
        Balance[] storage userBalances= balances[msg.sender];
        bool hasDeposit = false;
        uint256 _balanceindex=0;
        for (uint i =0;i<userBalances.length;i++){
            if(userBalances[i].token==_token && userBalances[i].amount>=_amount){
                hasDeposit=true;
                _balanceindex=i;
                break;
            }
        }
        assert(hasDeposit);
        item.isAvailable=false;
        ERC721 _contract = ERC721(items[_itemindex]._contract);
        _contract.transferFrom(address(this),msg.sender,item.id);
        balances[msg.sender][_balanceindex].amount -= _amount;
        ERC20 _tokencontract = ERC20(_token);
        _tokencontract.transfer(item.owner,_amount);
        emit Exchange(item.owner,msg.sender,_itemindex,_token,_amount);

    }

    //sells an NFT  by matching the buy offer previously created
    function sell(uint _itemindex, uint _bidindex) public{
        Item storage item = items[_itemindex];
        assert(item.isAvailable);
        Offer memory _bid = bids[_itemindex][_bidindex];
        assert(!_bid.isAsk);
        assert(_bid.isActive);
        address _token = _bid.paymentToken;
        uint256 _amount = _bid.paymentAmount;
        address _origin = _bid.origin;
        Balance[] storage userBalances= balances[_origin];
        bool hasDeposit = false;
        uint256 _balanceindex=0;
        for (uint i =0;i<userBalances.length;i++){
            if(userBalances[i].token==_token && userBalances[i].amount>=_amount){
                hasDeposit=true;
                _balanceindex=i;
                break;
            }
        }
        assert(hasDeposit);
        item.isAvailable=false;
        ERC721 _contract = ERC721(items[_itemindex]._contract);
        _contract.transferFrom(address(this),_origin,item.id);
        balances[_origin][_balanceindex].amount -= _amount;
        ERC20 _tokencontract = ERC20(_token);
        _tokencontract.transfer(item.owner,_amount);



    }

    //withdraws ERC20 previously deposited
    function withdraw(address _token, uint amount) public{
        Balance[] storage userBalances= balances[msg.sender];
        bool hasDeposit = false;
        uint256 _balanceindex=0;
        for (uint i =0;i<userBalances.length;i++){
            if(userBalances[i].token==_token && userBalances[i].amount>=amount){
                hasDeposit=true;
                _balanceindex=i;
                break;
            }
        }
        assert(hasDeposit);
        userBalances[_balanceindex].amount-=amount;
        ERC20 _tokenContract = ERC20(_token);
        _tokenContract.transfer(msg.sender,amount);
    }

    function cancelOrder(uint _itemindex,uint _offerindex,bool _isAsk) public{
        if(_isAsk){
            assert(asks[_itemindex][_offerindex].origin==msg.sender);
            asks[_itemindex][_offerindex].isActive=false;
            return();
        }
        assert(bids[_itemindex][_offerindex].origin==msg.sender);
        bids[_itemindex][_offerindex].isActive=false;
    }


}
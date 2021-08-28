// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";


contract SampleERC721 is ERC721{

    constructor(string memory name_,string memory symbol_) public ERC721(name_,symbol_){
    }

    function mint(address _to,uint id) public{
        super._mint(_to,id);

    }


}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

contract Marketplace is ERC1155 {

    using EnumerableSet for EnumerableSet.UintSet;

    uint256 public tokenSupply;
    mapping(uint256 => EnumerableSet.UintSet) private tokenIdMap;
    mapping(uint256 => mapping(uint256 => string)) private indexUriMap;
    mapping(uint256 => address) private ownerOf;

    constructor() ERC1155("") {}

    error NOT_IMPLEMENTED();    

    function getIndexURI(uint256 tokenId, uint256 indexId) public view returns(string memory) { 
        return indexUriMap[tokenId][indexId];
    }

    function getIndexId(uint256 tokenId, uint256 index) public view returns(uint256) {
        return tokenIdMap[tokenId].at(index);
    }

    function setURI(uint256 tokenId, uint256 indexId, string memory uri) public { 
        if(ownerOf[tokenId] == msg.sender && tokenIdMap[tokenId].contains(indexId)) {
            indexUriMap[tokenId][indexId] = uri;
        }
    }

    function mintNFTs(uint256 count, string[] memory tokenURIs) public {
        if(tokenURIs.length == count) {
            ownerOf[tokenSupply] = msg.sender;
            _mint(tokenSupply, count, tokenURIs);
            tokenSupply++;
        }
    }

    function increaseTokenSupply(uint256 tokenId, uint256 count, string[] memory tokenURIs) public {
        if(ownerOf[tokenId] == msg.sender && tokenURIs.length == count) {
            _mint(tokenId, count, tokenURIs);
        }
    }

    function _mint(uint256 tokenId, uint256 count, string[] memory tokenURIs) internal {
        _mint(msg.sender, tokenId, count, new bytes(0));

        uint256 curIndexSupply = tokenIdMap[tokenId].length();
        for(uint256 i = curIndexSupply; i < (curIndexSupply + count); i++) {
            tokenIdMap[tokenId].add(i);
            setURI(tokenId, i, tokenURIs[i - curIndexSupply]);
        }
    }

    function burnIndexIds(uint256 tokenId, uint256[] memory indexIds) public {
        if(ownerOf[tokenId] == msg.sender && indexIds.length > 0) {
            for(uint256 i; i < indexIds.length; i++) {
                _burnIndex(tokenId, indexIds[i]);
            }
        }
    }

    function burnTokenId(uint256 tokenId) public {
        for(uint256 i; i < tokenIdMap[tokenId].length(); i++) {
            indexUriMap[tokenId][tokenIdMap[tokenId].at(i)] = "";
            tokenIdMap[tokenId].remove(tokenIdMap[tokenId].at(i));
        }   
        _burn(msg.sender, tokenId, balanceOf(msg.sender, tokenId));
    }

    function _burnIndex(uint256 tokenId, uint256 indexId) internal {
        if(tokenIdMap[tokenId].contains(indexId)) {
            indexUriMap[tokenId][indexId] = indexUriMap[tokenId][tokenIdMap[tokenId].length() - 1];
            indexUriMap[tokenId][tokenIdMap[tokenId].length() - 1] = "";
            tokenIdMap[tokenId].remove(tokenIdMap[tokenId].at(tokenIdMap[tokenId].length() - 1));
            _burn(msg.sender, tokenId, 1);
        }
    }
    

    function safeTransferFrom(address, address, uint256, uint256, bytes memory) public override {
        revert NOT_IMPLEMENTED();
    }

    function safeBatchTransferFrom(address, address,uint256[] memory,uint256[] memory,bytes memory) public override {
        revert NOT_IMPLEMENTED();
    } 

}
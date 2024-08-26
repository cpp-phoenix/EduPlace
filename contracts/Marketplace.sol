// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "./LpERC20.sol";

contract Marketplace {

    address public EduPlaceTokenAddress;
    mapping(address => mapping(address => LPData)) lpBalances;
    mapping(address => address) nftLPContracts;
    mapping(address => uint256[]) public nftTokenIds;

    struct LPData {
        uint256 tokenBalance;
        uint256 NFTBalance;
        address lpTokenAddress;
    }

    constructor(address _EduPlaceTokenAddress) {
        EduPlaceTokenAddress = _EduPlaceTokenAddress;
    }

    function addLiquidity(address nftContract, uint256[] calldata tokenIds, uint256 amountEDPTokens) external {
        if(IERC721(nftContract).balanceOf(msg.sender) < tokenIds.length) {
            revert("Insufficient NFT balance");
        }

        if(IERC20(EduPlaceTokenAddress).balanceOf(msg.sender) < amountEDPTokens) {
            revert("Insufficient token balance");
        }

        uint length = tokenIds.length;

        LPData storage tokenBalances = lpBalances[msg.sender][nftContract];

        for(uint i; i < length; ) {

            IERC721(nftContract).transferFrom(msg.sender, address(this), tokenIds[i]);
            nftTokenIds[nftContract].push(tokenIds[i]);
            unchecked {
                i++;
            }
        }

        IERC20(EduPlaceTokenAddress).transferFrom(msg.sender, address(this), amountEDPTokens);

        tokenBalances.NFTBalance += length;
        tokenBalances.tokenBalance += amountEDPTokens;

        if(nftLPContracts[nftContract] == address(0)) {
            string memory lpName = string.concat('EDP-',ERC721(nftContract).name());
            nftLPContracts[nftContract] = address(new LpERC20(lpName,lpName));
        }

        tokenBalances.lpTokenAddress = nftLPContracts[nftContract];
        LpERC20(tokenBalances.lpTokenAddress).mint(msg.sender, length * amountEDPTokens);
    }

    function removeLiquidity(address nftContract, uint256 amountEDPTokens) external {
        LPData storage tokenBalances = lpBalances[msg.sender][nftContract];
        
        uint256 noOfNfts = tokenBalances.NFTBalance;
        if(tokenBalances.tokenBalance < amountEDPTokens || noOfNfts > nftTokenIds[nftContract].length) {
            revert("Insufficiend Balances");
        }

        if(IERC20(address(this)).balanceOf(msg.sender) < (noOfNfts * amountEDPTokens)) {
            revert("Insufficient LP Balance");
        }

        for(uint i; i < noOfNfts;) {
            tokenBalances.NFTBalance -= 1;
            IERC721(nftContract).transferFrom(address(this), msg.sender, nftTokenIds[nftContract][i]);

            unchecked {
                i++;
            }
        }

        for(uint i; i < noOfNfts;) {
            nftTokenIds[nftContract][i] = nftTokenIds[nftContract][noOfNfts - 1];
            nftTokenIds[nftContract].pop();

            unchecked {
                i++;
            }
        }

        IERC20(EduPlaceTokenAddress).transfer(msg.sender, amountEDPTokens);
        tokenBalances.tokenBalance -= amountEDPTokens;

        LpERC20(tokenBalances.lpTokenAddress).burn(msg.sender, (noOfNfts * amountEDPTokens));
    }

    function estimateSwapNFT(address nftContract, uint256[] calldata tokenIds) external view returns(uint256){
        uint256 contractNFTBalance = IERC721(nftContract).balanceOf(address(this));
        uint256 contractTokenBalance = IERC20(EduPlaceTokenAddress).balanceOf(address(this));

        uint amountTokenReceived = (contractTokenBalance * tokenIds.length) / (contractNFTBalance + tokenIds.length);
        
        return amountTokenReceived;
    }

    function swapNFT(address nftContract, uint256[] calldata tokenIds) external {
        uint256 contractNFTBalance = IERC721(nftContract).balanceOf(address(this));
        uint256 contractTokenBalance = IERC20(EduPlaceTokenAddress).balanceOf(address(this));

        uint amountTokenReceive = (contractTokenBalance * tokenIds.length) / (contractNFTBalance + tokenIds.length);

        if(amountTokenReceive > 0 && IERC20(EduPlaceTokenAddress).balanceOf(address(this)) > amountTokenReceive) {
            for(uint i; i < tokenIds.length; ) {
                IERC721(nftContract).transferFrom(msg.sender, address(this), tokenIds[i]);
                nftTokenIds[nftContract].push(tokenIds[i]);
                unchecked {
                    i++;
                }
            }
            IERC20(EduPlaceTokenAddress).transfer(msg.sender, amountTokenReceive);
        }
    }
    
    function quoteSwapToken(address nftContract, uint amountEDPTokens) external view returns(uint) {
        uint256 contractNFTBalance = IERC721(nftContract).balanceOf(address(this));
        uint256 contractTokenBalance = IERC20(EduPlaceTokenAddress).balanceOf(address(this));

        uint amountNFTReceived = ((contractNFTBalance * amountEDPTokens) / (contractTokenBalance + amountEDPTokens));

        return amountNFTReceived;
    }

    function swapToken(address nftContract, uint amountEDPTokens) external {
        uint256 contractNFTBalance = IERC721(nftContract).balanceOf(address(this));
        uint256 contractTokenBalance = IERC20(EduPlaceTokenAddress).balanceOf(address(this));

        uint amountNFTReceived = ((contractNFTBalance * amountEDPTokens) / (contractTokenBalance + amountEDPTokens));

        IERC20(EduPlaceTokenAddress).transferFrom(msg.sender, address(this), amountEDPTokens);

        if(amountNFTReceived > 0) {
            if(IERC721(nftContract).balanceOf(address(this)) >= amountNFTReceived) {
                for(uint i; i < amountNFTReceived;) {

                    IERC721(nftContract).transferFrom(address(this), msg.sender, nftTokenIds[nftContract][i]);
                    
                    unchecked {
                        i++;
                    }
                }

                for(uint i; i < amountNFTReceived;) {
                    nftTokenIds[nftContract][i] = nftTokenIds[nftContract][amountNFTReceived - 1];
                    nftTokenIds[nftContract].pop();
                    unchecked {
                        i++;
                    }
                }
            }
        }
    }
}

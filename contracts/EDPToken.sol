// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract EDPToken is ERC20 {

    constructor() ERC20("EDP","EDUPlACE"){
        
    }

    function mint(uint256 amount) public {
        super._mint(msg.sender, amount);
    } 
}
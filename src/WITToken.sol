// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

// import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "solmate/tokens/ERC20.sol";

contract WITToken is ERC20("Women In Tech Token", "WITT", 18){
  constructor(address user) {
      _mint(user, 2000000e18);
  }

}

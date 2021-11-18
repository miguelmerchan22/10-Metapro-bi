pragma solidity >=0.7.0;
// SPDX-License-Identifier: Apache 2.0

contract Ownable {
  address payable public owner;
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
  constructor(){
    owner = payable(msg.sender);
  }
  modifier onlyOwner() {
    if(msg.sender != owner)revert();
    _;
  }
  function transferOwnership(address payable newOwner) public onlyOwner {
    if(newOwner == address(0))revert();
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}
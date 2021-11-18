pragma solidity >=0.7.0;

// SPDX-License-Identifier: Apache 2.0

import "./Ownable.sol";

contract Admin is Ownable{
  mapping (address => bool) public admin;

  event NewAdmin(address indexed admin);
  event AdminRemoved(address indexed admin);

  constructor(){
    admin[msg.sender] = true;
  }

  modifier onlyAdmin() {
    if(!admin[msg.sender])revert();
    _;
  }

  function makeNewAdmin(address payable _newadmin) public onlyOwner {
    if(_newadmin == address(0))revert();
    emit NewAdmin(_newadmin);
    admin[_newadmin] = true;
  }

  function makeRemoveAdmin(address payable _oldadmin) public onlyOwner {
    if(_oldadmin == address(0))revert();
    emit AdminRemoved(_oldadmin);
    admin[_oldadmin] = false;
  }

}
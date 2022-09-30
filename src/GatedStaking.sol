// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "solmate/tokens/ERC20.sol";


contract GatedStaking {

  event Staked(address indexed user, uint256 amount);
  event Withdrawn(address indexed user, uint256 amount);
  event InterestCompounded(address indexed user, uint256 amount);

  address public WITToken;
  address public boredApeNFT = 0xBC4CA0EdA7647A8aB7C2061c2E118A18a936f13D;

  uint256 factor = 1e11;
  uint256 delta = 3854;

  struct Staker {
    address stakerAddress;
    uint256 amountStaked;
    uint256 timeStaked;
  }

  mapping (address => Staker) public currentStakers;

  constructor(address _WITToken) {
        require(address(_WITToken) != address(0),"Contract Address cannot be address 0");      
        WITToken = _WITToken;
  }


  function checkContractTokenBalance() public view returns(uint){
    return address(this).balance;
  }

  function stakeToken(address _staker, uint256 _amountToStake) public payable {

    Staker storage s = currentStakers[_staker];
    require(_amountToStake > 0, "You need to stake at least 1 WITToken");
    require(ERC20(WITToken).balanceOf(_staker) >= _amountToStake, "Insufficient Balance");
    require(BoredApeNFT(boredApeNFT).balanceOf(_staker) >= 1, "You can't stake because you don't have boredApeNFT");
    if (s.amountStaked > 0) {
        uint256 currentRewards = getRewards(msg.sender);
        s.amountStaked += currentRewards;
        emit InterestCompounded(msg.sender, currentRewards);
    }

   assert(ERC20(WITToken).transferFrom(_staker, address(this), _amountToStake));

    s.stakerAddress = _staker;
    s.amountStaked += _amountToStake;
    s.timeStaked = block.timestamp;
    emit Staked(msg.sender, _amountToStake);
  }
  

  function withdraw(uint256 _amount) public payable {
    Staker memory s = currentStakers[msg.sender];
    require(s.stakerAddress == msg.sender, "You are not a staker of this token");
    require(s.amountStaked > 0, "You dont have a stake yet");
    assert(s.amountStaked >= _amount);

    uint256 totalMoneyToSend = _amount;
    totalMoneyToSend += getRewards(msg.sender);

    s.amountStaked -= _amount;
    s.timeStaked = block.timestamp;

    assert(ERC20(WITToken).transfer(msg.sender, totalMoneyToSend));
    emit Withdrawn(msg.sender, totalMoneyToSend);
  }

  function getRewards(address _user)
        internal
        view
        returns (uint256 interest__)
    {
        Staker memory u = currentStakers[_user];
        if (u.amountStaked > 0) {
            uint256 currentAmount = u.amountStaked;
            uint256 lastTime = u.timeStaked;
            uint256 duration = (block.timestamp) - lastTime;
            interest__ = delta * duration * currentAmount;
            interest__ /= factor;
        }
  }

  function getUser(address _user) public view returns (Staker memory u) {
      u = currentStakers[_user];
  }

  
}

interface BoredApeNFT {
    function balanceOf(address owner) external view returns (uint256);
}
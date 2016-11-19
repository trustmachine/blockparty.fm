pragma solidity ^0.4.3;

contract Owned {
  function Owned() {
    owner = msg.sender;
  }

  modifier onlyowner() {
    if (msg.sender == owner) {
      _;
    }
  }
  address public owner;
}


contract OwnedProxy is Owned {
  function forward_transaction(address _destination, uint _value, bytes _calldata) public onlyowner {
    if (!_destination.call.value(_value)(_calldata)) {
      throw;
    }
  }

  function transfer_ownership(address _owner) public onlyowner {
    owner = _owner;
  }
}

contract BlockParty is OwnedProxy {
  modifier valueGreaterThanPrice() {
    if (msg.value >= price) {
      _;
    } else {
      throw;
    }
  }

  modifier inOperation() {
    if (operational) {
      _;
    } else {
      throw;
    }
  }

  function () inOperation() valueGreaterThanPrice() public {
    amount[msg.sender] += msg.value;
    AmountPayed(msg.sender, msg.value);
  }

  function BlockParty(address _owner, address _payoutDestination, uint _price) {
    owner = _owner;
    price = _price;
    payoutDestination = _payoutDestination;
    operational = true;
  }

  function setPrice(uint _price) onlyowner public {
    price = _price;
  }

  function setOperational(bool _state) onlyowner public {
    operational = _state;
  }

  function setPayoutDestination(address _payoutDestination) onlyowner public {
    payoutDestination = _payoutDestination;
  }

  function payout() onlyowner public {
    forward_transaction(payoutDestination, this.balance, "");
  }

  event AmountPayed(address _sender, uint _amount);

  bool public operational;
  uint public price;
  address public payoutDestination;
  mapping(address => uint) public amount;
}

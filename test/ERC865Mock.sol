pragma solidity ^0.4.24;

import "./../contracts/ERC865BasicToken.sol";

contract ERC865BasicTokenMock is ERC865BasicToken {
    constructor(
        address _initialAccount,
        uint256 _initialBalance,
        address _feeAccount,
        bytes _signature2
    )
        public
    {
        balances[_initialAccount] = _initialBalance;
        totalSupply_ = _initialBalance;
        feeAccount = _feeAccount;
        signatures[_signature2] = true;
    }
}

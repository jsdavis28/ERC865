pragma solidity 0.4.25;

import "./ERC865.sol";

/**
 * @title ExampleERC865
 * @author jsdavis28
 * @dev This token implements a demo of the ERC865 standard.
 */

contract ExampleERC865 is ERC865 {
    /**
     * @dev Sets token information.
     */
    string public name = "ERC865DemoV1";
    string public symbol = "865v1";
    uint8 public decimals = 0;
    uint256 public INITIAL_SUPPLY;

    constructor() public {
        _mint(msg.sender, 1000);
        INITIAL_SUPPLY = balanceOf(msg.sender);
    }
}

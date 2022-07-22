pragma solidity 0.4.25;

/**
 * @title IERC865
 * @author jsdavis28
 * @dev Simpler version of the ERC865 interface from https://github.com/ethereum/EIPs/issues/865 and
 *  https://github.com/RobertMCForster/CoinvestV2Audit/blob/master/contracts/CoinvestTokenV2.sol
 * @notice ERC865Token allows for users to pay gas costs in an ERC20 token to a delegate
 *  https://github.com/ethereum/EIPs/issues/865
 */
 contract IERC865 {
     function cancelPreSigned(
        bytes _signature,
        address _token,
        address _from,
        uint256 _nonce,
        uint256 _reward
     )
        public;

     function transferPreSigned(
        bytes _signature,
        address _token,
        address _from,
        address _to,
        uint256 _value,
        uint256 _fee,
        uint256 _nonce
     )
        public;

    event CancelPreSigned(
        address indexed delegate,
        address indexed from,
        uint256 nonce,
        uint256 reward);

     event TransferPreSigned(
        address indexed delegate,
        address indexed from,
        address indexed to,
        uint256 value,
        uint256 fee);
}

pragma solidity 0.4.25;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "./IERC865.sol";

/**
 * @title ERC865
 * @author jsdavis28
 * @dev Simpler version of the ERC865 token from https://github.com/ethereum/EIPs/issues/865 and
 *  https://github.com/RobertMCForster/CoinvestV2Audit/blob/master/contracts/CoinvestTokenV2.sol
 * @notice ERC865Token allows for users to pay gas costs in an ERC20 token to a delegate
 *  https://github.com/ethereum/EIPs/issues/865
 */

 contract ERC865 is IERC865, ERC20 {
    /**
     * @dev Sets arrays to protect against used signatures and cancelled transactions
     */
    mapping(bytes => bool) internal _signatures;
    mapping(address => mapping(uint256 => bool)) internal _cancellations;

    /**
     * @dev Allows a delegate to cancel an approved transaction on behalf of the token holder.
     * @param _signature : The signature created by the token holder.
     * @param _token : The token being transfered.
     * @param _from : The token holder.
     * @param _nonce : The transfer unique identifier.
     * @param _reward : The payment made to the delegate.
     */
    function cancelPreSigned(
        bytes _signature,
        address _token,
        address _from,
        uint256 _nonce,
        uint256 _reward
    )
        public
    {
        //Pre-validate transaction
        require(_signatures[_signature] == false);
        require(_cancellations[_from][_nonce] == false);
        require(address(this) == _token);

        //Create a hash of the transaction details
        bytes32 hashedTx = _cancelPreSignedHashing(_token, _nonce, _reward);

        //Obtain the token holder's address
        address from = _recover(hashedTx, _signature);
        require(from == _from);

        //Set transaction as cancelled
        _cancellations[from][_nonce] = true;

        //Pay reward
        _transfer(from, msg.sender, _reward);

        //Set transaction as completed
        _signatures[_signature] = true;

        //CancelPresigned ERC865 event
        emit CancelPreSigned(msg.sender, _from, _nonce, _reward);
        
        //Transfer ERC20 event
        emit Transfer(from, msg.sender, _reward);
    }

    /**
     * @dev Allows a delegate to submit a transaction on behalf of the token holder.
     * @param _signature : The signature created by the token holder.
     * @param _token : The token being transfered.
     * @param _to : The recipient's address.
     * @param _value : The amount of tokens to be transferred.
     * @param _fee : The amount of tokens paid to the delegate for gas costs.
     * @param _nonce : The transfer unique identifier.
     */
    function transferPreSigned(
        bytes _signature,
        address _token,
        address _from,
        address _to,
        uint256 _value,
        uint256 _fee,
        uint256 _nonce
    )
        public
    {
        //Pre-validate transaction
        require(_to != address(0));
        require(_signatures[_signature] == false);
        require(_cancellations[_from][_nonce] == false);
        require(address(this) == _token);

        //Create a hash of the transaction details
        bytes32 hashedTx = _transferPreSignedHashing(_token, _to, _value, _fee, _nonce);

        //Obtain the token holder's address and check balance
        address from = _recover(hashedTx, _signature);
        require(from == _from);
        uint256 total = _value.add(_fee);
        require(total <= balanceOf(from));

        //Transfer tokens
        _transfer(from, _to, _value);
        _transfer(from, msg.sender, _fee);

        //Set transaction as completed
        _signatures[_signature] = true;

        //TransferPreSigned ERC865 event
        emit TransferPreSigned(msg.sender, from, _to, _value, _fee);
        
        //Transfer ERC20 events
        emit Transfer(from, _to, _value);
        emit Transfer(from, feeAccount, _fee);
    }

    /**
     * @dev Creates a hash of the transaction information passed to cancelPresigned.
     * @param _token : The token being transfered.
     * @param _nonce : The transfer unique identifier.
     * @param _reward :  The payment made to the delegate.
     * @return : A copy of the hashed message signed by the token holder, with prefix added.
     */
    function _cancelPreSignedHashing(
        address _token,
        uint256 _nonce,
        uint256 _reward
    )
        internal
        pure
        returns (bytes32)
    {
        //Create a copy of thehashed message signed by the token holder
        bytes32 hash = keccak256(abi.encodePacked(_token, _nonce, _reward));

        //Add prefix to hash
        return _prefix(hash);
    }

    /**
     * @dev Creates a hash of the transaction information passed to transferPresigned.
     * @param _token : The token being transfered.
     * @param _to : The address which you want to transfer to.
     * @param _value : The amount of tokens to be transferred.
     * @param _fee : The amount of tokens paid to msg.sender, by the owner.
     * @param _nonce : The transfer unique identifier.
     * @return : A copy of the hashed message signed by the token holder, with prefix added.
     */
    function _transferPreSignedHashing(
        address _token,
        address _to,
        uint256 _value,
        uint256 _fee,
        uint256 _nonce
    )
        internal
        pure
        returns (bytes32)
    {
        //Create a copy of thehashed message signed by the token holder
        bytes32 hash = keccak256(abi.encodePacked(_token, _to, _value, _fee, _nonce));

        //Add prefix to hash
        return _prefix(hash);
    }

    /**
     * @dev Adds prefix to the hashed message signed by the token holder.
     * @param _hash : The hashed message (keccak256) to be prefixed.
     * @return : Prefixed hashed message to return from _transferPreSignedHashing.
     */
    function _prefix(bytes32 _hash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _hash));
    }

    /**
     * @dev Validate the transaction information and recover the token holder's address.
     * @param _hash : A prefixed version of the hash used in the original signed message.
     * @param _sig : The signature submitted by the token holder.
     * @return : The token holder's address.
     */
    function _recover(bytes32 _hash, bytes _sig) internal pure returns (address) {
        bytes32 r;
        bytes32 s;
        uint8 v;

        //Check the signature length
        if (_sig.length != 65) {
            return (address(0));
        }

        //Split the signature into r, s and v variables
        assembly {
            r := mload(add(_sig, 32))
            s := mload(add(_sig, 64))
            v := byte(0, mload(add(_sig, 96)))
        }

        //Version of signature should be 27 or 28, but 0 and 1 are also possible
        if (v < 27) {
            v += 27;
        }

        //If the version is correct, return the signer address
        if (v != 27 && v != 28) {
            return (address(0));
        } else {
            return ecrecover(_hash, v, r, s);
        }
    }
}

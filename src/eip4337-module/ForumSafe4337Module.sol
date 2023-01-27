// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.15;

import {Utils} from '@utils/Utils.sol';

import {BaseAccount, IEntryPoint, IAccount, UserOperation} from '@eip4337/contracts/core/BaseAccount.sol';

/**
 * @notice 4337 Account implementation for ForumSafeModule
 * @author Forum
 * @dev A first pass at integrating 4337 with ForumSafeModule
 */

contract ForumSafe4337Module is BaseAccount {
	/// ----------------------------------------------------------------------------------------
	///							ACCOUNT STORAGE
	/// ----------------------------------------------------------------------------------------

	uint256 internal _nonce;

	// 2D version used to allow out of order execution
	mapping(bytes32 => uint256) public usedNonces;

	// Entry point allowed to call methods directly on this contract
	IEntryPoint internal _entryPoint;

	// Validation logic contract - allows for updating validaion requirements
	IAccount public validationLogic;

	/// ----------------------------------------------------------------------------------------
	///							ACCOUNT LOGIC
	/// ----------------------------------------------------------------------------------------

	// Incremented for each execute called here (not for extension based called for now)
	function nonce() public view virtual override returns (uint256) {
		return _nonce;
	}

	function entryPoint() public view virtual override returns (IEntryPoint) {
		return _entryPoint;
	}

	// ! very minimal validation, not secure at all
	function _validateSignature(
		UserOperation calldata userOp,
		bytes32 userOpHash,
		address
	) internal virtual override returns (uint256 sigTimeRange) {
		// userOp.sigs should be a hash of the userOpHash, and the proposal hash for this contract
		// consider restrictions on what entrypoint can call?

		return validationLogic.validateUserOp(userOp, userOpHash, address(this), 0);

		//return isOwner(recoveredSigner) ? 0 : SIG_VALIDATION_FAILED;
	}

	/// implement template method of BaseAccount
	function _validateAndUpdateNonce(UserOperation calldata userOp) internal override {
		bytes32 userOpHash = _entryPoint.getUserOpHash(userOp);
		require(usedNonces[userOpHash] == 0, 'op already used');
		usedNonces[userOpHash] = 1;
		++_nonce;
	}

	function getRequiredSignatures() public view virtual returns (uint256) {
		// ! implement argent style check on allowed methods for single signer vs all sigs

		// check functions on this contract
		// check functions as the module
		// check batched or multicall calls

		return 0;
	}
}

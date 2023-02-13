// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.15;

// 4337 imports
import {EntryPoint} from '@eip4337/contracts/core/EntryPoint.sol';
import {BaseAccount, UserOperation} from '@eip4337/contracts/core/BaseAccount.sol';

// 4337 contracts
import {EIP4337Account} from '../../../src/eip4337-account/EIP4337Account.sol';
import {EIP4337AccountFactory} from '../../../src/eip4337-account/EIP4337AccountFactory.sol';
import {EIP4337ValidationManager} from '../../../src/eip4337-account/EIP4337ValidationManager.sol';
import {EIP4337GroupAccount} from '../../../src/eip4337-module/EIP4337GroupAccount.sol';
import {ForumSafe4337Factory} from '../../../src/eip4337-module/ForumSafe4337Factory.sol';

// EllipticCurve validator used for p256 curves - compiled with v0.5.0
/// @dev To save changes to folder structure, this is built elsewhere and added to the ./out folder
///		 The file is the same as utils/EllipticCurve.sol, except uses 'pragma solidity 0.5.0;'
import {IEllipticCurveValidator} from '@interfaces/IEllipticCurveValidator.sol';

import './SafeTestConfig.t.sol';
import './ForumModuleTestConfig.t.sol';

contract Helper4337 is Test, SafeTestConfig, ForumModuleTestConfig {
	// 4337 Account Types
	// Entry point
	EntryPoint public entryPoint;
	// Singleton for Forum 4337 account implementation
	EIP4337Account public eip4337Singleton;
	// Singleton for Forum 4337 group account implementation
	EIP4337GroupAccount public eip4337GroupSingleton;
	// Validation manager used to check signatures for a 4337 group
	EIP4337ValidationManager public eip4337ValidationManager;
	// Factory for individual 4337 accounts
	EIP4337AccountFactory public eip4337AccountFactory;
	// Factory for 4337 group accounts
	ForumSafe4337Factory public forumSafe4337Factory;
	// Elliptic curve validator
	IEllipticCurveValidator public ellipticCurveValidator;

	// Addresses for easy use in tests
	address internal entryPointAddress;
	address internal eip4337ValidationManagerAddress;

	// Stuct for sigs to be decoded by p256 solidity library
	struct TestSig {
		uint[2] sig;
		uint[2] signer;
		bytes32 message;
	}

	constructor() {
		entryPoint = new EntryPoint();
		entryPointAddress = address(entryPoint);

		eip4337ValidationManager = new EIP4337ValidationManager();
		eip4337ValidationManagerAddress = address(eip4337ValidationManager);

		// Validator used for p256 curves
		ellipticCurveValidator = IEllipticCurveValidator(
			deployCode('EllipticCurve5.sol:EllipticCurve5')
		);

		eip4337Singleton = new EIP4337Account(ellipticCurveValidator);
		eip4337GroupSingleton = new EIP4337GroupAccount();

		eip4337AccountFactory = new EIP4337AccountFactory(
			eip4337Singleton,
			entryPoint,
			address(handler)
		);
		forumSafe4337Factory = new ForumSafe4337Factory(
			payable(address(eip4337GroupSingleton)),
			address(safeSingleton),
			address(handler),
			address(multisend),
			address(safeProxyFactory),
			address(entryPoint),
			eip4337ValidationManagerAddress,
			address(fundraiseExtension),
			address(withdrawalExtension),
			address(0)
		);
	}

	// -----------------------------------------------------------------------
	// User Op Templates
	// -----------------------------------------------------------------------

	// Base for a  User Operation
	// ! create multiple with gas profiles to match tests
	UserOperation public userOpBase =
		UserOperation({
			sender: address(0),
			nonce: 0,
			initCode: new bytes(0),
			callData: new bytes(0),
			callGasLimit: 100000,
			verificationGasLimit: 10000000,
			preVerificationGas: 21000000,
			maxFeePerGas: 2,
			maxPriorityFeePerGas: 1e9,
			paymasterAndData: new bytes(0),
			signature: new bytes(0)
		});

	// -----------------------------------------------------------------------
	// Signature Templates
	// -----------------------------------------------------------------------

	TestSig internal testSig1 =
		TestSig({
			sig: [
				0x535b670719b8510bcf71a9713c23f0dadff3ec73bca56e472d01976ca16d88b7,
				0xb4b64109a6a35302be6297bc0c7444e117c6e0185caa71d11486ad04f33f8ddd
			],
			signer: [
				0xd3c6949ab309ff80296ffb17cd2a5298ec23ad7f1fda03ca70f12353987303de,
				0x42c164839f37f10fb2e6e5649c046a473a8d4db61d0602433fe32484d1c2d8d3
			],
			message: 0xf2424746de28d3e593fb6af9c8dff6d24de434350366e60312aacfe79dae94a8
		});

	TestSig internal testSig2 =
		TestSig({
			sig: [
				0x0fb0aa68dce6f1517cfb4cad4659a3ea403edc9f31994dd6bd2e1945df0f11bb,
				0x83479be56839e8c3e089613a02dd09f1a035751db0cb4fcf728bf94a231e0285
			],
			signer: [
				0x7088c8f47cbe4745dc5e9e44302dcf1a528766b48470dea245076b8e91ebe2c5,
				0xe498cf1f4f1ed27c1db3e78d389673bb40f26fc7d2d9e3ae8ca247ff3ba6c570
			],
			message: 0x75f6954424c5ac191d504086214ca53c4d0d199fcfd47da90364eab2aa98a31d
		});

	// account 0x3092CE9e547BadF2173327c2FB1dC1094B11934c, 0.4 eth transfer to alice, nonce 0
	TestSig internal testSig3 =
		TestSig({
			sig: [
				0x0fb0aa68dce6f1517cfb4cad4659a3ea403edc9f31994dd6bd2e1945df0f11bb,
				0x83479be56839e8c3e089613a02dd09f1a035751db0cb4fcf728bf94a231e0285
			],
			signer: [
				0x7088c8f47cbe4745dc5e9e44302dcf1a528766b48470dea245076b8e91ebe2c5,
				0xe498cf1f4f1ed27c1db3e78d389673bb40f26fc7d2d9e3ae8ca247ff3ba6c570
			],
			message: ''
		});

	bytes authenticatorDataBufferHex =
		bytes('0x1584482fdf7a4d0b7eb9d45cf835288cb59e55b8249fff356e33be88ecc546d11d00000000');

	// -----------------------------------------------------------------------
	// 4337 Helper Functions
	// -----------------------------------------------------------------------

	function getNonce(BaseAccount account) internal view returns (uint256) {
		return account.nonce();
	}

	function buildUserOp(
		uint8 testSignatureData,
		address sender,
		uint256 nonce,
		bytes memory initCode,
		bytes memory callData
	) public view returns (UserOperation memory userOp) {
		// Build on top of base op
		userOp = userOpBase;

		// Add sender and calldata to op
		userOp.sender = sender;
		userOp.nonce = nonce;
		userOp.initCode = initCode;
		userOp.callData = callData;

		// Improve this now we have multiple
		TestSig memory testSig = testSignatureData == 1 ? testSig1 : testSignatureData == 2
			? testSig2
			: testSig3;

		userOp.signature = abi.encode([testSig.sig[0], testSig.sig[1]], authenticatorDataBufferHex);
	}

	// Build payload which the entryPoint will call on the sender 4337 account
	function buildExecutionPayload(
		address to,
		uint256 value,
		bytes memory data,
		Enum.Operation operation
	) internal pure returns (bytes memory) {
		return
			abi.encodeWithSignature(
				'execute(address,uint256,bytes,uint8)',
				to,
				value,
				data,
				operation
			);
		// abi.encode(operationType, _accounts, _amounts, _payloads);
	}

	// Calculate gas used by sender of userOp
	// ! currently only works when paymaster set to 0 - hence 'address(0) != address(0)'
	function calculateGas(UserOperation memory userOp) internal pure returns (uint256) {
		uint256 mul = address(0) != address(0) ? 3 : 1;
		uint256 requiredGas = userOp.callGasLimit +
			userOp.verificationGasLimit *
			mul +
			userOp.preVerificationGas;

		return requiredGas * userOp.maxFeePerGas;
	}
}

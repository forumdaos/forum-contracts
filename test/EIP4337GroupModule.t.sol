// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.15;

// import './helpers/ForumSafeTestConfig.t.sol';
import './config/EIP4337TestConfig.t.sol';

import {SignatureHelper} from './config/SignatureHelper.t.sol';

contract Module4337Test is EIP4337TestConfig, SignatureHelper {
	ForumGroupModule private forumSafeModule;
	GnosisSafe private safe;

	/// -----------------------------------------------------------------------
	/// Setup
	/// -----------------------------------------------------------------------

	function setUp() public {
		// (
		// 	// Deploy a forum safe from the factory
		// 	forumSafeModule,
		// 	safe
		// ) = forumGroupFactory.deployForumSafe(
		// 	'test',
		// 	'T',
		// 	[uint32(50), uint32(80)],
		// 	voters,
		// 	initialExtensions
		// );
		// // Set addresses for easier use in tests
		// moduleAddress = address(forumSafeModule);
		// safeAddress = address(safe);
		// vm.deal(safeAddress, 1 ether);
	}

	/// -----------------------------------------------------------------------
	/// Tests
	/// -----------------------------------------------------------------------

	function testSetupGroup() public {
		uint256[2] memory publicKey = createPublicKey();
		uint256[2] memory publicKey2 = createPublicKey();

		uint256[] memory membersX = new uint256[](2);
		membersX[0] = publicKey[0];
		membersX[1] = publicKey2[1];

		uint256[] memory membersY = new uint256[](2);
		membersY[0] = publicKey[0];
		membersY[1] = publicKey2[1];

		(
			// Deploy a forum safe from the factory
			forumSafeModule,
			safe
		) = forumGroupFactory.deployForumSafe(
			'test',
			'T',
			[uint32(50), uint32(80)],
			membersX,
			membersY,
			initialExtensions
		);
	}

	// function testExecutionViaEntryPoint() public {
	// 	// check balance before
	// 	assertTrue(address(alice).balance == 1 ether);
	// 	assertTrue(address(safe).balance == 1 ether);
	// 	assertTrue(forumSafeModule.nonce() == 0);

	// 	// build a proposal
	// 	bytes memory executeCalldata = buildExecutionPayload(
	// 		Enum.Operation.Call,
	// 		[alice],
	// 		[uint256(0.5 ether)],
	// 		[new bytes(0)]
	// 	);

	// 	// build user operation
	// 	UserOperation memory tmp = buildUserOp(
	// 		address(forumSafeModule),
	// 		new bytes(0),
	// 		executeCalldata,
	// 		alicePk
	// 	);

	// 	UserOperation[] memory tmp1 = new UserOperation[](1);
	// 	tmp1[0] = tmp;

	// 	entryPoint.handleOps(tmp1, payable(alice));

	// 	// Transfer has been made, nonce incremented, used nonce set
	// 	assertTrue(address(alice).balance == 1.5 ether);
	// 	assertTrue(address(safe).balance == 0.5 ether);
	// 	assertTrue(forumSafeModule.nonce() == 1);
	// 	assertTrue(forumSafeModule.usedNonces(entryPoint.getUserOpHash(tmp)) == 1);
	// }

	// function testManageAdminViaEntryPoint() public {
	// 	// check balance before
	// 	assertTrue(forumSafeModule.memberVoteThreshold() == 50);

	// 	// build a proposal
	// 	bytes memory manageAdminCalldata = buildManageAdminPayload(
	// 		IForumSafeModuleTypes.ProposalType.MEMBER_THRESHOLD,
	// 		[address(0)],
	// 		[uint256(60)],
	// 		[new bytes(0)]
	// 	);

	// 	// build user operation
	// 	UserOperation memory tmp = buildUserOp(forumSafeModule, manageAdminCalldata, alicePk);

	// 	UserOperation[] memory tmp1 = new UserOperation[](1);
	// 	tmp1[0] = tmp;

	// 	entryPoint.handleOps(tmp1, payable(alice));

	// 	assertTrue(forumSafeModule.memberVoteThreshold() == 60);
	// }
}

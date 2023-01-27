// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.15;

// import './helpers/ForumSafeTestConfig.t.sol';
import './helpers/Helper4337.t.sol';

import {EIP4337Manager} from '../../src/eip4337-manager/EIP4337Manager.sol';

contract Module4337Test is Helper4337 {
	ForumSafe4337Module private forumSafeModule;
	GnosisSafe private safe;

	EIP4337Manager private validationLogic;

	/// -----------------------------------------------------------------------
	/// Setup
	/// -----------------------------------------------------------------------

	function setUp() public {
		initialExtensions[0] = entryPointAddress;
		initialExtensions.push(address(validationLogic));
		(
			// Deploy a forum safe from the factory
			forumSafeModule,
			safe
		) = forumSafe4337Factory.deployForumSafe(
			'test',
			'T',
			[uint32(50), uint32(80)],
			voters,
			initialExtensions
		);

		// Set addresses for easier use in tests
		moduleAddress = address(forumSafeModule);
		safeAddress = address(safe);

		vm.deal(safeAddress, 1 ether);
	}

	/// -----------------------------------------------------------------------
	/// Tests
	/// -----------------------------------------------------------------------

	function testExecutionViaEntryPoint() public {
		// check balance before
		assertTrue(address(alice).balance == 1 ether);
		assertTrue(address(safe).balance == 1 ether);

		// build a proposal
		bytes memory executeCalldata = buildExecutionPayload(
			Enum.Operation.Call,
			[alice],
			[uint256(0.5 ether)],
			[new bytes(0)]
		);

		// build user operation
		UserOperation memory tmp = buildUserOp(forumSafeModule, executeCalldata, alicePk);

		UserOperation[] memory tmp1 = new UserOperation[](1);
		tmp1[0] = tmp;

		entryPoint.handleOps(tmp1, payable(alice));

		assertTrue(address(alice).balance == 1.5 ether);
		assertTrue(address(safe).balance == 0.5 ether);
	}

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

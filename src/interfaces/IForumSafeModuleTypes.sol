// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

/// @notice Forum module interface for sharing types
interface IForumSafeModuleTypes {
	enum ProposalType {
		MINT, // add membership
		BURN, // revoke membership
		CALL, // call contracts
		VPERIOD, // set `votingPeriod`
		MEMBER_LIMIT, // set `memberLimit`
		MEMBER_THRESHOLD, // set `memberVoteThreshold`
		TOKEN_THRESHOLD, // set `tokenVoteThreshold`
		TYPE, // set `VoteType` to `ProposalType`
		PAUSE, // flip membership transferability
		EXTENSION, // flip `extensions` whitelisting
		ESCAPE, // delete pending proposal in case of revert
		DOCS, // amend org docs
		ALLOW_CONTRACT_SIG // enable the contract to sign as an EOA
	}

	enum VoteType {
		MEMBER, // % of members required to pass
		SIMPLE_MAJORITY, // over 50% total votes required to pass
		TOKEN_MAJORITY // user set % of total votes required to pass
	}

	struct Proposal {
		uint48 proposalDetails; // packed creation time (uint32), ProposalType,  Enum.Operation (from safe)
		address[] accounts; // member(s) being added/kicked; account(s) receiving payload
		uint256[] amounts; // value(s) to be minted/burned/spent; gov setting [0]
		bytes[] payloads; // data for CALL proposals
	}

	struct Signature {
		uint8 v;
		bytes32 r;
		bytes32 s;
	}
}
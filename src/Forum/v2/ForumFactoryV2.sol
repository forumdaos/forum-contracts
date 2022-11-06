// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.13;

import {Owned} from "../../utils/Owned.sol";

import {ForumGroup, Multicall} from "../ForumGroup.sol";

/// @notice Factory to deploy forum group.
contract ForumFactoryV2 is Multicall, Owned {
    /// ----------------------------------------------------------------------------------------
    /// Errors and Events
    /// ----------------------------------------------------------------------------------------

    event GroupDeployed(
        ForumGroup indexed forumGroup,
        string name,
        string symbol,
        address[] voters,
        uint32[4] govSettings
    );

    error NullDeploy();

    error MintingClosed();

    error MemberLimitExceeded();

    /// ----------------------------------------------------------------------------------------
    /// Factory Storage
    /// ----------------------------------------------------------------------------------------

    address public forumMaster;
    address public forumRelay;
    address public fundraiseExtension;
    address public executionManager;
    address public pfpStaker;

    bool public factoryLive = false;

    /// ----------------------------------------------------------------------------------------
    /// Constructor
    /// ----------------------------------------------------------------------------------------

    constructor(
        address deployer,
        address forumMaster_,
        address executionManager_
    ) Owned(deployer) {
        forumMaster = forumMaster_;

        executionManager = executionManager_;
    }

    /// ----------------------------------------------------------------------------------------
    /// Owner Interface
    /// ----------------------------------------------------------------------------------------

    function setLaunched(bool setting) external onlyOwner {
        factoryLive = setting;
    }

    function setForumMaster(address forumMaster_) external onlyOwner {
        forumMaster = forumMaster_;
    }

    function setForumRelay(address forumRelay_) external onlyOwner {
        forumRelay = forumRelay_;
    }

    function setPfpStaker(address pfpStaker_) external onlyOwner {
        pfpStaker = pfpStaker_;
    }

    function setFundraiseExtension(address fundraiseExtension_)
        external
        onlyOwner
    {
        fundraiseExtension = fundraiseExtension_;
    }

    function setExecutionManager(address executionManager_) external onlyOwner {
        executionManager = executionManager_;
    }

    /// ----------------------------------------------------------------------------------------
    /// Factory Logic
    /// ----------------------------------------------------------------------------------------

    function deployGroup(
        string memory name_,
        string memory symbol_,
        address[] calldata voters_,
        uint32[4] memory govSettings_
    ) public payable virtual returns (ForumGroup forumGroup) {
        if (!factoryLive)
            if (msg.sender != forumRelay) revert MintingClosed();

        if (voters_.length > 100) revert MemberLimitExceeded();

        forumGroup = ForumGroup(_cloneAsMinimalProxy(forumMaster, name_));

        address[3] memory initialExtensions = [
            address(pfpStaker),
            executionManager,
            fundraiseExtension
        ];

        forumGroup.init{value: msg.value}(
            name_,
            symbol_,
            voters_,
            initialExtensions,
            govSettings_
        );

        emit GroupDeployed(forumGroup, name_, symbol_, voters_, govSettings_);
    }

    /// @dev modified from Aelin (https://github.com/AelinXYZ/aelin/blob/main/contracts/MinimalProxyFactory.sol)
    function _cloneAsMinimalProxy(address base, string memory name_)
        internal
        virtual
        returns (address payable clone)
    {
        bytes memory createData = abi.encodePacked(
            // constructor
            bytes10(0x3d602d80600a3d3981f3),
            // proxy code
            bytes10(0x363d3d373d3d3d363d73),
            base,
            bytes15(0x5af43d82803e903d91602b57fd5bf3)
        );

        bytes32 salt = keccak256(bytes(name_));

        assembly {
            clone := create2(
                0, // no value
                add(createData, 0x20), // data
                mload(createData),
                salt
            )
        }
        // if CREATE2 fails for some reason, address(0) is returned
        if (clone == address(0)) revert NullDeploy();
    }
}
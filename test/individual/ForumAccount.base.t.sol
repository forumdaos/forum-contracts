// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.15;

import "../config/ERC4337TestConfig.t.sol";

import {Enum} from "../../src/erc4337-account/ForumAccount.sol";
import {PrecomputeGenerator} from "../config/PrecomputeGenerator.t.sol";

/**
 * @notice This contract contains some variables and functions used to test the ForumAccount contract
 * 			It is inherited by each ForumAccount test file
 */
contract ForumAccountTestBase is ERC4337TestConfig {
    ForumAccount internal forumAccount;

    address payable internal forumAccountAddress;

    address internal precompute1 = address(0x1111);
    address internal precompute2 = address(0x2222);

    bytes internal basicTransferCalldata;

    PrecomputeGenerator internal precomputeGenerator = new PrecomputeGenerator();

    /// -----------------------------------------------------------------------
    /// HELPERS
    /// -----------------------------------------------------------------------

    function accountSalt(uint256[2] memory owner) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(owner));
    }

    // TODO make this more general
    function createPrecomputeAddress(uint256[2] memory publicKey, uint256[2] memory publicKey2) internal {
        vm.etch(precompute1, precomputeGenerator.generatePrecomputeTable(publicKey));
        vm.etch(precompute2, precomputeGenerator.generatePrecomputeTable(publicKey2));
    }

    receive() external payable { // Allows this contract to receive ether
    }
}

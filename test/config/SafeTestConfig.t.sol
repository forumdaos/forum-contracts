// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Safe imports
import {Safe, Enum} from "@safe/Safe.sol";
import {MultiSend} from "@safe/libraries/MultiSend.sol";

// SafeTestTools imports
/// @dev Take care that the test lib gitmodule for Safe matches ours
import {
    SafeTestTools,
    CompatibilityFallbackHandler,
    SafeProxyFactory,
    SignMessageLib
} from "../../lib/safe-tools/src/SafeTestTools.sol";

// General setup helper for all safe contracts
contract SafeTestConfig is SafeTestTools {
    MultiSend internal multisend;
    SignMessageLib internal signMessageLib;

    // Used to store the address of the safe created in tests
    address internal safeAddress;

    /// -----------------------------------------------------------------------
    /// Setup
    /// -----------------------------------------------------------------------

    constructor() {
        multisend = new MultiSend();
        signMessageLib = new SignMessageLib();
    }

    /// -----------------------------------------------------------------------
    /// Utils
    /// -----------------------------------------------------------------------

    function buildSafeMultisend(
        Enum.Operation operation,
        address to,
        uint256 value,
        bytes memory data
    ) internal pure returns (bytes memory) {
        // Encode the multisend transaction
        // (needed to delegate call from the safe as addModule is 'authorised')
        bytes memory tmp = abi.encodePacked(operation, to, value, uint256(data.length), data);

        // Create multisend payload
        return abi.encodeWithSignature("multiSend(bytes)", tmp);
    }
}

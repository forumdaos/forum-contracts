// SPDX-License-Identifier UNLICENSED
pragma solidity ^0.8.13;

/* solhint-disable no-console */

import {BasicTestConfig} from "./BasicTestConfig.t.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

/**
 * @notice - This contract runs the FCL_ecdsa_precompute.sage script
 * 			 It is used to create the precomputed table used to verify signatures
 */
contract PrecomputeGenerator is BasicTestConfig {
    function generatePrecomputeTable(uint256[2] memory publicKey) public returns (bytes memory) {
        string[] memory cmd = new string[](5);

        cmd[0] = "sage";
        cmd[1] = "-c";
        cmd[2] = string(abi.encodePacked("C0=", Strings.toString(publicKey[0]), ";"));
        cmd[3] = string(abi.encodePacked("C1=", Strings.toString(publicKey[1]), ";"));
        cmd[4] = 'load("script/sage/FCL_ecdsa_precompute.sage")';

        bytes memory res = vm.ffi(cmd);

        return res;
    }
}

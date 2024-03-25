// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.15;

import {
    OnitSafeTestCommon,
    Enum,
    PackedUserOperation,
    OnitSafe,
    OnitSafeProxyFactory,
    Onit4337Wrapper,
    console
} from "../OnitSafe.common.t.sol";

import {UUPSUpgradeable} from "../../lib/webauthn-sol/lib/solady/src/utils/UUPSUpgradeable.sol";

/**
 * @notice Some variables and functions used to test the Onit Safe Module
 */
contract OnitSafeTestBase is OnitSafeTestCommon {
    bytes32 internal constant _ERC1967_IMPLEMENTATION_SLOT =
        0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    /// -----------------------------------------------------------------------
    /// Setup
    /// -----------------------------------------------------------------------
    function setUp() public virtual {
        // Deploy contracts
        onitSingleton = new OnitSafe();
        onitSafeFactory = new OnitSafeProxyFactory(address(handler), address(onitSingleton));

        onitAccount = OnitSafe(payable(onitSafeFactory.createAccount(publicKeyBase, keccak256("a"))));
        onitAccountAddress = payable(address(onitAccount));

        // Deal funds to account
        deal(onitAccountAddress, 1 ether);

        // Build a basic transaction to execute in some tests
        //basicTransferCalldata = buildExecutionPayload(alice, uint256(0.5 ether), "", Enum.Operation.Call);
    }

    /// -----------------------------------------------------------------------
    /// Setup tests
    /// -----------------------------------------------------------------------

    function testCannotSetupSingleton() public {
        // Try to setup the Onit function on singleton
        vm.expectRevert(OnitSafe.AlreadyInitialized.selector);
        onitSingleton.setupOnitSafe(publicKeyBase);

        // Check that the owner is still the placeholder
        assertEq(onitSingleton.owner()[0], 1);
        assertEq(onitSingleton.owner()[1], 1);

        address[] memory owners = new address[](1);
        owners[0] = address(0xdead);

        // Try to setup the safe function on singleton
        vm.expectRevert("GS200");
        onitSingleton.setup(owners, 1, address(0), new bytes(0), address(0), address(0), 0, payable(0));
    }

    function testOnitAccountDeployedCorrectly() public {
        // Safe variables set
        assertEq(onitAccount.getOwners()[0], address(0xdead));
        assertEq(onitAccount.getThreshold(), 1);
        // todo check fallback handler

        // Onit4337Wrapper variables set
        assertEq(address(onitAccount.entryPoint()), entryPointAddress);
        assertEq(onitAccount.getNonce(), 0);
        assertEq(onitAccount.owner()[0], publicKeyBase[0]);
        assertEq(onitAccount.owner()[1], publicKeyBase[1]);
    }

    /// -----------------------------------------------------------------------
    /// Validation tests
    /// -----------------------------------------------------------------------

    function testFailsIfNotFromEntryPoint() public {
        onitAccount.validateUserOp(userOpBase, entryPoint.getUserOpHash(userOpBase), 0);
    }

    function testValidateUserOp() public {
        // Some basic user operation
        PackedUserOperation memory userOp = buildUserOp(onitAccountAddress, 0, new bytes(0), new bytes(0));

        // Sign the user operation and format signature into webauthn format to verify
        userOp = webauthnSignUserOperation(userOp, passkeyPrivateKey);

        bytes memory validateUserOpCalldata =
            abi.encodeWithSelector(OnitSafe.validateUserOp.selector, userOp, entryPoint.getUserOpHash(userOp), 0);

        // We prank entrypoint and call like this for _requireFromEntryPoint check
        vm.prank(entryPointAddress);
        (, bytes memory validationData) = onitAccountAddress.call(validateUserOpCalldata);
        assertEq(keccak256(validationData), keccak256(abi.encodePacked(uint256(0))));

        userOp.signature = new bytes(200);
        validateUserOpCalldata =
            abi.encodeWithSelector(OnitSafe.validateUserOp.selector, userOp, entryPoint.getUserOpHash(userOp), 0);

        // Returns 1 for  failed signature verification
        vm.prank(entryPointAddress);
        (, validationData) = onitAccountAddress.call(validateUserOpCalldata);
        assertEq(keccak256(validationData), keccak256(abi.encodePacked(uint256(1))));
    }

    function testValidateUserOpWithPrefund() public {
        // Some basic user operation
        PackedUserOperation memory userOp = buildUserOp(onitAccountAddress, 0, new bytes(0), new bytes(0));

        // Sign the user operation and format signature into webauthn format to verify
        userOp = webauthnSignUserOperation(userOp, passkeyPrivateKey);

        bytes memory validateUserOpCalldata = abi.encodeWithSelector(
            OnitSafe.validateUserOp.selector, userOp, entryPoint.getUserOpHash(userOp), 0.5 ether
        );

        // We prank entrypoint and call like this for _requireFromEntryPoint check
        vm.prank(entryPointAddress);
        (, bytes memory validationData) = onitAccountAddress.call(validateUserOpCalldata);

        assertEq(keccak256(validationData), keccak256(abi.encodePacked(uint256(0))));
        assertEq(onitAccountAddress.balance, 0.5 ether);
    }

    // todo isValidSignature 1271 test

    /// -----------------------------------------------------------------------
    /// Execution tests
    /// -----------------------------------------------------------------------

    function testExecuteTx() public {
        // Init values for test
        uint256 aliceBalanceBefore = alice.balance;
        uint256 onitAccountBalanceBefore = onitAccountAddress.balance;
        uint256 transferAmount = 0.1 ether;

        // Some transfer user operation
        bytes memory transferExecutionCalldata =
            buildExecutionPayload(alice, transferAmount, new bytes(0), Enum.Operation.Call);

        PackedUserOperation memory userOp = buildUserOp(onitAccountAddress, 0, new bytes(0), transferExecutionCalldata);

        // Sign the user operation and format signature into webauthn format to verify
        userOp = webauthnSignUserOperation(userOp, passkeyPrivateKey);

        PackedUserOperation[] memory userOps = new PackedUserOperation[](1);
        userOps[0] = userOp;

        entryPoint.handleOps(userOps, payable(alice));

        // Check that the transfer was executed
        assertEq(alice.balance, aliceBalanceBefore + transferAmount);
        assertEq(onitAccountAddress.balance, onitAccountBalanceBefore - transferAmount);
    }

    function testETHReceived() public {
        (bool success,) = onitAccountAddress.call{value: 1 ether}("");
        assertTrue(success);
    }

    // todo test other receive functions

    // /// -----------------------------------------------------------------------
    // /// Upgrade tests
    // /// -----------------------------------------------------------------------

    function testUpgradeTo() public {
        OnitSafe impl2 = new OnitSafe();

        vm.prank(entryPointAddress);
        onitAccount.upgradeToAndCall(address(impl2), bytes(""));

        bytes32 v = vm.load(onitAccountAddress, _ERC1967_IMPLEMENTATION_SLOT);
        assertEq(address(uint160(uint256(v))), address(impl2));
    }

    function testUpgradeToRevertWithUnauthorized() public {
        vm.expectRevert(Onit4337Wrapper.NotFromEntryPoint.selector);
        onitAccount.upgradeToAndCall(DEAD_ADDRESS, bytes(""));
    }

    function testUpgradeToRevertWithUpgradeFailed() public {
        vm.expectRevert(UUPSUpgradeable.UpgradeFailed.selector);
        onitAccount.upgradeToAndCall(address(0xABCD), bytes(""));
    }

    // todo consider upgrateToAndCall tests
    // todo consider delegation and proxy guard tests

    // /// -----------------------------------------------------------------------
    // /// Utils
    // /// -----------------------------------------------------------------------

    // Build payload which the entryPoint will call on the sender Onit 4337 account
    function buildExecutionPayload(
        address to,
        uint256 value,
        bytes memory data,
        Enum.Operation operation
    ) internal pure returns (bytes memory) {
        return abi.encodeWithSignature("execute(address,uint256,bytes,uint8)", to, value, data, uint8(0));
    }
}
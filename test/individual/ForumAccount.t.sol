// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.15;

import {Enum} from "../../src/erc4337-account/ForumAccount.sol";
import "../config/ERC4337TestConfig.t.sol";

contract ForumAccountTest is ERC4337TestConfig {
    // Variable used for test erc4337 account
    ForumAccount private deployed4337Account;
    address payable private deployed4337AccountAddress;

    bytes internal basicTransferCalldata;

    /// -----------------------------------------------------------------------
    /// Setup
    /// -----------------------------------------------------------------------

    function setUp() public {
        publicKey = createPublicKey(SIGNER_1);
        publicKey2 = createPublicKey(SIGNER_2);

        // Check 4337 singelton is set in factory (base implementation for Forum 4337 accounts)
        assertEq(
            address(forumAccountFactory.forumAccountSingleton()),
            address(forumAccountSingleton),
            "forumAccountSingleton not set"
        );
        // Check 4337 entryPoint is set in factory
        assertEq(forumAccountFactory.entryPoint(), entryPointAddress, "entryPoint not set");
        // Check 4337 gnosis fallback handler is set in factory
        assertEq(address(forumAccountFactory.gnosisFallbackLibrary()), address(handler), "handler not set");
        // Can not initialize the singleton
        vm.expectRevert("GS200");
        forumAccountSingleton.initialize(entryPointAddress, publicKey, address(1), "", "", "");

        // Deploy an account to be used in tests later
        deployed4337AccountAddress = forumAccountFactory.createForumAccount(publicKey);
        deployed4337Account = ForumAccount(deployed4337AccountAddress);

        // Deal funds to account
        deal(deployed4337AccountAddress, 1 ether);

        // Build a basic transaction to execute in some tests
        basicTransferCalldata = buildExecutionPayload(alice, uint256(0.5 ether), "", Enum.Operation.Call);
    }

    /// -----------------------------------------------------------------------
    /// Deployment tests
    /// -----------------------------------------------------------------------

    function testFactoryCreateAccount() public {
        // Check that the account from setup is deployed and data is set on account, and safe
        assertEq(deployed4337Account.owner()[0], publicKey[0], "owner not set");
        assertEq(deployed4337Account.owner()[1], publicKey[1], "owner not set");
        assertEq(deployed4337Account.getThreshold(), 1, "threshold not set");
        assertEq(deployed4337Account.getOwners()[0], address(0xdead), "owner not set on safe");
        assertEq(address(deployed4337Account.entryPoint()), address(entryPoint), "entry point not set");

        // Can not initialize the same account twice
        vm.expectRevert("GS200");
        deployed4337Account.initialize(entryPointAddress, publicKey, address(1), "", "", "");
    }

    function testFactoryDeployFromEntryPoint() public {
        //Encode the calldata for the factory to create an account
        bytes memory factoryCalldata = abi.encodeWithSignature("createForumAccount(uint256[2])", publicKey2);

        //Prepend the address of the factory
        bytes memory initCode = abi.encodePacked(address(forumAccountFactory), factoryCalldata);

        // Calculate address in advance to use as sender
        address preCalculatedAccountAddress = (forumAccountFactory).getAddress(accountSalt(publicKey2));
        // Deal funds to account
        deal(preCalculatedAccountAddress, 1 ether);
        // Cast to ForumAccount - used to make some test assertions easier
        ForumAccount testNew4337Account = ForumAccount(payable(preCalculatedAccountAddress));

        UserOperation[] memory userOps = signAndFormatUserOpIndividual(
            buildUserOp(preCalculatedAccountAddress, 0, initCode, basicTransferCalldata), SIGNER_2
        );

        // Handle userOp
        entryPoint.handleOps(userOps, payable(alice));

        // Check that the account is deployed and data is set on account, and safe
        assertEq(testNew4337Account.owner()[0], publicKey2[0], "owner not set");
        assertEq(testNew4337Account.owner()[1], publicKey2[1], "owner not set");
        assertEq(testNew4337Account.getThreshold(), 1, "threshold not set");
        assertEq(testNew4337Account.getOwners()[0], address(0xdead), "owner not set on safe");
        assertEq(address(testNew4337Account.entryPoint()), entryPointAddress, "entry point not set");
    }

    function testCorrectAddressCrossChain() public {
        address tmpMumbai;
        address tmpFuji;

        // Fork Mumbai and create an account from a fcatory
        vm.createSelectFork(vm.envString("MUMBAI_RPC_URL"));

        forumAccountFactory = new ForumAccountFactory(
    		forumAccountSingleton,
    		entryPointAddress, 
    		address(handler),
    		'',
    '',
    ''
    	);

        // Deploy an account to be used in tests
        tmpMumbai = forumAccountFactory.createForumAccount(publicKey);

        // Fork Fuji and create an account from a fcatory
        vm.createSelectFork(vm.envString("FUJI_RPC_URL"));

        forumAccountFactory = new ForumAccountFactory(
    		forumAccountSingleton,
    		entryPointAddress,
    		address(handler),
    		'',
    '',
    ''
    	);

        // Deploy an account to be used in tests
        tmpFuji = forumAccountFactory.createForumAccount(publicKey);

        assertEq(tmpMumbai, tmpFuji, "address not the same");
    }

    /// -----------------------------------------------------------------------
    /// Function tests
    /// -----------------------------------------------------------------------

    function testValidateUserOp() public {
        // Build user operation
        UserOperation memory userOp = buildUserOp(deployed4337AccountAddress, 0, "", basicTransferCalldata);
        userOp.signature =
            abi.encode(signMessageForPublicKey(SIGNER_1, Base64.encode(abi.encodePacked(entryPoint.getUserOpHash(userOp)))));

        vm.startPrank(entryPointAddress);
        deployed4337Account.validateUserOp(userOp, entryPoint.getUserOpHash(userOp), 0);
    }

    function testOnlyEntryPoint() public {
        vm.expectRevert();
        deployed4337Account.validateUserOp(buildUserOp(deployed4337AccountAddress, 0, "", basicTransferCalldata), 0, 0);

        vm.expectRevert();
        deployed4337Account.executeAndRevert(address(this), 0, "", Enum.Operation.Call);
    }

    /// -----------------------------------------------------------------------
    /// Execution tests
    /// -----------------------------------------------------------------------

    // ! consider a limit to prevent changing entrypoint to a contract that is not compatible with 4337
    function testUpdateEntryPoint() public {
        // Check old entry point is set
        assertEq(address(deployed4337Account.entryPoint()), entryPointAddress, "entry point not set");

        // Build userop to set entrypoint to this contract as a test
        UserOperation memory userOp = buildUserOp(
            deployed4337AccountAddress,
            entryPoint.getNonce(deployed4337AccountAddress, BASE_NONCE_KEY),
            "",
            abi.encodeWithSignature("setEntryPoint(address)", address(this))
        );

        UserOperation[] memory userOps = signAndFormatUserOpIndividual(userOp, SIGNER_1);

        // Handle userOp
        entryPoint.handleOps(userOps, payable(this));

        // Check that the entry point has been updated
        assertEq(address(deployed4337Account.entryPoint()), address(this), "entry point not updated");
    }

    function testAccountTransfer() public {
        // Build user operation
        UserOperation memory userOp = buildUserOp(deployed4337AccountAddress, 0, "", basicTransferCalldata);

        UserOperation[] memory userOps = signAndFormatUserOpIndividual(userOp, SIGNER_1);

        // Check nonce before tx
        assertEq(entryPoint.getNonce(deployed4337AccountAddress, BASE_NONCE_KEY), 0, "nonce not correct");

        // Handle userOp
        entryPoint.handleOps(userOps, payable(address(this)));

        uint256 gas = calculateGas(userOp);

        // Check updated balances
        assertEq(deployed4337AccountAddress.balance, 0.5 ether - gas, "balance not updated");
        assertEq(alice.balance, 1.5 ether, "balance not updated");

        // Check account nonce
        assertEq(entryPoint.getNonce(deployed4337AccountAddress, BASE_NONCE_KEY), 1, "nonce not updated");
    }

    // Simulates adding an EOA owner to the safe (can act as a guardian in case of loss)
    function testAccountAddOwner() public {
        // Build payload to enable a module
        bytes memory addOwnerPayload =
            abi.encodeWithSignature("addOwnerWithThreshold(address,uint256)", address(this), 1);

        bytes memory payload =
            buildExecutionPayload(deployed4337AccountAddress, 0, addOwnerPayload, Enum.Operation.Call);

        // Build user operation
        UserOperation memory userOp = buildUserOp(
            deployed4337AccountAddress, entryPoint.getNonce(deployed4337AccountAddress, BASE_NONCE_KEY), "", payload
        );

        UserOperation[] memory userOps = signAndFormatUserOpIndividual(userOp, SIGNER_1);

        // Check nonce before tx
        assertEq(entryPoint.getNonce(deployed4337AccountAddress, BASE_NONCE_KEY), 0, "nonce not correct");

        // Handle userOp
        entryPoint.handleOps(userOps, payable(address(this)));

        uint256 gas = calculateGas(userOp);

        // Check updated balances
        assertEq(deployed4337AccountAddress.balance, 1 ether - gas, "balance not updated");
        // Check account nonce
        assertEq(entryPoint.getNonce(deployed4337AccountAddress, BASE_NONCE_KEY), 1, "nonce not updated");
        // Check module is enabled
        assertTrue(deployed4337Account.isOwner(address(this)), "owner not added");
    }

    // ! Double check with new validation including the domain seperator
    function testCannotReplaySig() public {
        // Build user operation
        UserOperation memory userOp = buildUserOp(deployed4337AccountAddress, 0, "", basicTransferCalldata);

        UserOperation[] memory userOps = signAndFormatUserOpIndividual(userOp, SIGNER_1);

        // Check nonce before tx
        assertEq(entryPoint.getNonce(deployed4337AccountAddress, BASE_NONCE_KEY), 0, "nonce not correct");

        // Handle first userOp
        entryPoint.handleOps(userOps, payable(address(this)));

        assertEq(entryPoint.getNonce(deployed4337AccountAddress, BASE_NONCE_KEY), 1, "nonce not correct");

        vm.expectRevert();
        entryPoint.handleOps(userOps, payable(address(this)));
    }

    function testAddAndRemoveGuardian() public {
        address[] memory owners = deployed4337Account.getOwners();
        assertEq(owners.length, 1, "should start with 1 owner");

        vm.startPrank(deployed4337AccountAddress);

        // Simulate adding an owner
        deployed4337Account.addOwnerWithThreshold(address(this), 1);

        owners = deployed4337Account.getOwners();
        assertEq(owners.length, 2, "owner not added");
        assertEq(owners[0], address(this), "incorrect owner");

        // Simulate swapping an owner (address(1) indicates sentinel owner, which is 'prev' in linked list)
        deployed4337Account.swapOwner(address(1), address(this), alice);

        owners = deployed4337Account.getOwners();
        assertEq(owners.length, 2, "incorrect number of owners");
        assertEq(owners[0], alice, "incorrect owner");

        // Simulate removing an owner
        deployed4337Account.removeOwner(address(1), alice, 1);

        owners = deployed4337Account.getOwners();
        assertEq(owners.length, 1, "owner not removed");
        assertEq(owners[0], address(0xdead), "incorrect owner");
    }

    /// -----------------------------------------------------------------------
    /// Helper functions
    /// -----------------------------------------------------------------------

    function accountSalt(uint256[2] memory owner) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(owner));
    }

    receive() external payable { // Allows this contract to receive ether
    }
}
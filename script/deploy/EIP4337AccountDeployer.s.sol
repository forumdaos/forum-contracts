// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {EIP4337Account} from '../../src/eip4337-account/EIP4337Account.sol';
import {IEllipticCurveValidator} from '@interfaces/IEllipticCurveValidator.sol';
import {DeploymentSelector} from '../../lib/foundry-deployment-manager/src/DeploymentSelector.sol';

/**
 * @dev This contract is used to deploy the EIP4337Account contract
 * For now this must be run before the EIP4337FactoryDeployer
 * Improvements to the deployment manager will allow this to be run in any order
 */
contract EIP4337AccountDeployer is DeploymentSelector {
	EIP4337Account internal account;

	address internal validator = 0x30f67C247d0339d6b7C9763a1815E6ba1de82F44;

	function run() public {
		innerRun();
		outputDeployment();
	}

	function innerRun() public {
		startBroadcast();

		bytes memory initData = abi.encode(validator);

		(address contractAddress, bytes memory deploymentBytecode) = SelectDeployment(
			'EIP4337Account',
			initData
		);

		fork.set('EIP4337Account', contractAddress, deploymentBytecode);

		stopBroadcast();
	}
}

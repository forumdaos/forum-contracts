// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ForumGroup} from '../../src/erc4337-group/ForumGroup.sol';
import {DeploymentSelector} from '../../lib/foundry-deployment-manager/src/DeploymentSelector.sol';

/**
 * @dev This contract is used to deploy the ForumGroup contract
 * For now this must be run before the ForumGroupFactoryDeployer
 * Improvements to the deployment manager will allow this to be run in any order
 */
contract ForumGroupDeployer is DeploymentSelector {
	ForumGroup internal forumGroup;

	string internal clientDataStart = '{"type":"webauthn.get","challenge":"';
	string internal clientDataEndDevelopment = '","origin":"https://development.forumdaos.com"}';
	string internal clientDataEndProduction = '","origin":"https://production.forumdaos.com"}';

	function run() public {
		innerRun();
		outputDeployment();
	}

	function innerRun() public {
		startBroadcast();

		string memory usedEnding = clientDataEndDevelopment;

		// If we are in production, use the production client data ending
		if (vm.envBool('PRODUCTION')) usedEnding = clientDataEndProduction;

		// No longer using external validator
		bytes memory initData = new bytes(0);

		(address contractAddress, bytes memory deploymentBytecode) = SelectDeployment(
			'ForumGroup',
			initData
		);

		fork.set('ForumGroup', contractAddress, deploymentBytecode);

		stopBroadcast();
	}
}

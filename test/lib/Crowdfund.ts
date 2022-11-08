import { expect } from '../utils/expect'

import { TOKEN, ZERO_ADDRESS } from '../config'
import { ForumGroupV2, ForumFactoryV2, ForumCrowdfund } from '../../typechain'

import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { BigNumber, Contract, ContractFactory, ethers, Signer } from 'ethers'
import { deployments, ethers as hardhatEthers } from 'hardhat'
import { beforeEach, describe, it } from 'mocha'
import { advanceTime } from '../utils/helpers'

// Defaults to e18 using amount * 10^18
function getBigNumber(amount: number, decimals = 18) {
	return BigNumber.from(amount).mul(BigNumber.from(10).pow(decimals))
}

describe.only('Crowdfund', function () {
	let forum: ForumGroupV2 // ForumGroup contract instance
	let forumFactory: ForumFactoryV2 // ForumFactory contract instance
	let crowdfund: ForumCrowdfund // Crowdfund contract instance
	let pfpStaker: Contract // pfpStaker contract instance
	let proposer: SignerWithAddress // signerA
	let alice: SignerWithAddress // signerB
	let bob: SignerWithAddress // signerC
	let crowdsaleInput: any // demo input for crowdsale
	let testGroupNameHash: string // hash of test group name, used to locate crowdfun on contract

	beforeEach(async () => {
		;[proposer, alice, bob] = await hardhatEthers.getSigners()

		// Similar to deploying the master forum multisig
		await deployments.fixture(['Forum', 'Shields'])
		forum = await hardhatEthers.getContract('ForumGroupV2')
		forumFactory = await hardhatEthers.getContract('ForumFactoryV2')
		crowdfund = await hardhatEthers.getContract('ForumCrowdfund')
		pfpStaker = await hardhatEthers.getContract('PfpStaker')

		// Setp deployments with correct addresses
		await forumFactory.setPfpStaker(pfpStaker.address)
		await forumFactory.setFundraiseExtension(ZERO_ADDRESS)

		crowdsaleInput = {
			targetContract: forumFactory.address,
			targetPrice: getBigNumber(2),
			deadline: 1730817411, // 05-11-2030
			groupName: 'TEST',
			symbol: 'T',
			payload: ethers.utils.toUtf8Bytes(
				'0x5d150a9500000000000000000000000000000000000000000000000000000000000000e000000000000000000000000000000000000000000000000000000000000001200000000000000000000000000000000000000000000000000000000000000160000000000000000000000000000000000000000000000000000000000003f48000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033000000000000000000000000000000000000000000000000000000000000003400000000000000000000000000000000000000000000000000000000000000066c6567656e64000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000064c4547454e4400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000adcc9add0b124cd933bfed9c7e53f520933d0fb4'
			)
		}

		// Generate hash of groupname used to locate crowdfund on contract
		testGroupNameHash = ethers.utils.keccak256(
			ethers.utils.defaultAbiCoder.encode(['string'], [crowdsaleInput.groupName])
		)

		// Initiate a fund used in tests below
		await crowdfund.initiateCrowdfund(crowdsaleInput, { value: getBigNumber(1) })
	})
	it('Should initiate crowdsale and submit contribution', async function () {
		const crowdfundDetails = await crowdfund.getCrowdfund(testGroupNameHash)

		// Check initial state
		expect(crowdfundDetails.details.targetContract).to.equal(crowdsaleInput.targetContract)
		expect(crowdfundDetails.details.targetPrice).to.equal(crowdsaleInput.targetPrice)
		expect(crowdfundDetails.details.deadline).to.equal(crowdsaleInput.deadline)
		expect(crowdfundDetails.details.groupName).to.equal(crowdsaleInput.groupName)
		expect(crowdfundDetails.details.symbol).to.equal(crowdsaleInput.symbol)
		expect(crowdfundDetails.contributors[0]).to.equal(proposer.address)
		//expect(crowdfundDetails.payload).to.equal(crowdsaleInput.payload)

		await crowdfund.connect(alice).submitContribution(testGroupNameHash),
			{
				value: getBigNumber(1)
			}

		const crowdfundDetailsAfterSubmission = await crowdfund.getCrowdfund(testGroupNameHash)

		// Check updated state
		console.log(crowdfundDetailsAfterSubmission.contributors)
		console.log(crowdfundDetailsAfterSubmission.contributions)
		expect(crowdfundDetailsAfterSubmission.contributors).to.have.lengthOf(2)
		expect(crowdfundDetailsAfterSubmission.contributions).to.have.lengthOf(2)
		expect(crowdfundDetailsAfterSubmission.details.targetContract).to.equal(
			crowdsaleInput.targetContract
		)
	})
	it('Should submit second contribution', async function () {
		const crowdfundDetails = await crowdfund.getCrowdfund(testGroupNameHash)

		// Check initial state
		expect(crowdfundDetails.contributors).to.have.lengthOf(1)
		expect(crowdfundDetails.contributors[0]).to.equal(proposer.address)
		expect(crowdfundDetails.contributions[0]).to.equal(getBigNumber(1))

		await crowdfund.submitContribution(testGroupNameHash, {
			value: getBigNumber(1)
		})

		const crowdfundDetailsAfterSubmission = await crowdfund.getCrowdfund(testGroupNameHash)

		// Check updated state
		expect(crowdfundDetailsAfterSubmission.contributors).to.have.lengthOf(1)
		expect(crowdfundDetailsAfterSubmission.contributors[0]).to.equal(proposer.address)
		expect(crowdfundDetailsAfterSubmission.contributions[0]).to.equal(getBigNumber(2))
	})
	// TODO need a check for previously deployed group with same name - create2 will fail, we should catch this
	it('Should revert if crowdsale for duplicate name exists', async function () {
		await expect(crowdfund.initiateCrowdfund(crowdsaleInput)).to.be.revertedWith('OpenFund()')
	})
	it.skip('Should revert submitting a contribution if no fund exists, over 12 people, or incorrect value', async function () {
		// Check if fund already exists
		await expect(
			crowdfund.submitContribution(
				ethers.utils.keccak256(ethers.utils.defaultAbiCoder.encode(['string'], ['WRONG']))
			)
		).to.be.revertedWith('MissingCrowdfund()')

		// Test limit beyond 100
		for (let i = 0; i < 102; i++) {
			const wallet = ethers.Wallet.createRandom()
			const w = wallet.connect(hardhatEthers.provider)
			// Send eth
			proposer.sendTransaction({
				to: w.address,
				value: ethers.utils.parseEther('1')
			})
			if (i < 99) {
				await crowdfund.connect(w).submitContribution(testGroupNameHash, {
					value: ethers.utils.parseEther('0.0000000000001')
				})
			} else {
				await expect(
					crowdfund.connect(w).submitContribution(testGroupNameHash, {
						value: 1
					})
				).to.be.revertedWith('MemberLimitReached()')
			}
		}
	})
	it('Should cancel a crowdfund and revert if not cancellable', async function () {
		// Can not cancel before deadline
		await expect(crowdfund.cancelCrowdfund(testGroupNameHash)).to.be.revertedWith('OpenFund()')

		advanceTime(1730817412)

		// Cancel the crowdfund and check the balance has been returned
		const bal1 = await hardhatEthers.provider.getBalance(proposer.address)
		await crowdfund.cancelCrowdfund(testGroupNameHash)
		const bal2 = await hardhatEthers.provider.getBalance(proposer.address)
		expect(bal2).to.be.gt(bal1)
	})
	it('Should process a crowdfund', async function () {
		// Process crowdfund
		const tx = await (await crowdfund.processCrowdfund(testGroupNameHash)).wait()

		// Get group deployed by crowdfund and check balance of member
		const group = `0x${tx.events[1].topics[1].substring(26)}`
		const groupContract = await hardhatEthers.getContractAt('ForumGroupV2', group)
		expect(await groupContract.balanceOf(proposer.address, 0)).to.equal(1)

		// ! check commission
	})

	// it('Should process native `value` crowdfund with unitValue multiplier', async function () {
	// 	// Delete existing crowdfund for test
	// 	await crowdfund.cancelFundRound(forum.address);

	// 	// unitValue = 2/1 so the contributors should get 1/2 of their contribution in group tokens
	// 	await crowdfund
	// 		.connect(proposer)
	// 		.initiateFundRound(
	// 			forum.address,
	// 			hardhatEthers.utils.parseEther('2'),
	// 			hardhatEthers.utils.parseEther('1'),
	// 			{ value: getBigNumber(50) }
	// 		);

	// 	await crowdfund
	// 		.connect(alice)
	// 		.submitFundContribution(forum.address, { value: getBigNumber(50) });

	// 	await crowdfund.processFundRound(forum.address);

	// 	// After processing, the accounts should be given tokens, and dao balance should be updated
	// 	expect(await hardhatEthers.provider.getBalance(forum.address)).to.equal(
	// 		getBigNumber(100)
	// 	);
	// 	expect(await hardhatEthers.provider.getBalance(crowdfund.address)).to.equal(
	// 		getBigNumber(0)
	// 	);
	// 	// Token balaces are 25 -> 1/2 of 50 as we have applied the unitValue multiplier
	// 	expect(await forum.balanceOf(proposer.address, TOKEN)).to.equal(
	// 		getBigNumber(25)
	// 	);
	// 	expect(await forum.balanceOf(alice.address, TOKEN)).to.equal(
	// 		getBigNumber(25)
	// 	);

	// 	// unitValue = 1/2 so the contributors should get 2 times their contribution in group tokens
	// 	await crowdfund
	// 		.connect(proposer)
	// 		.initiateFundRound(
	// 			forum.address,
	// 			hardhatEthers.utils.parseEther('1'),
	// 			hardhatEthers.utils.parseEther('2'),
	// 			{ value: getBigNumber(50) }
	// 		);

	// 	await crowdfund
	// 		.connect(alice)
	// 		.submitFundContribution(forum.address, { value: getBigNumber(50) });

	// 	await crowdfund.processFundRound(forum.address);

	// 	// After processing, the accounts should be given tokens, and dao balance should be updated (200 since second crowdfund)
	// 	expect(await hardhatEthers.provider.getBalance(forum.address)).to.equal(
	// 		getBigNumber(200)
	// 	);
	// 	expect(await hardhatEthers.provider.getBalance(crowdfund.address)).to.equal(
	// 		getBigNumber(0)
	// 	);
	// 	// Token balaces are 125 -> 1/2 of 50 from prev fun + 100 from current
	// 	expect(await forum.balanceOf(proposer.address, TOKEN)).to.equal(
	// 		getBigNumber(125)
	// 	);
	// 	expect(await forum.balanceOf(alice.address, TOKEN)).to.equal(
	// 		getBigNumber(125)
	// 	);
	// });
	// it('Should revert if non member initiates funraise', async function () {
	// 	// Delete existing crowdfund for test
	// 	await crowdfund.cancelFundRound(forum.address);

	// 	await expect(
	// 		crowdfund
	// 			.connect(bob)
	// 			.initiateFundRound(forum.address, 1, 1, { value: getBigNumber(50) })
	// 	).revertedWith('NotMember()');
	// });
	// it('Should revert if a fund is already open', async function () {
	// 	await expect(
	// 		crowdfund
	// 			.connect(proposer)
	// 			.initiateFundRound(forum.address, 1, 1, { value: getBigNumber(50) })
	// 	).revertedWith('OpenFund()');
	// });
	// it('Should revert if incorrect value sent', async function () {
	// 	await expect(
	// 		crowdfund
	// 			.connect(alice)
	// 			.submitFundContribution(forum.address, { value: getBigNumber(5000) })
	// 	).revertedWith('IncorrectContribution()');
	// });
	// it('Should revert if no fund is open', async function () {
	// 	// Delete other crowdfund
	// 	await crowdfund.cancelFundRound(forum.address);

	// 	// Need to set value to 0 as there is no individualContribution set yet
	// 	await expect(
	// 		crowdfund
	// 			.connect(alice)
	// 			.submitFundContribution(forum.address, { value: 0 })
	// 	).revertedWith('FundraiseMissing()');
	// });
	// it('Should revert if not all members have contributed', async function () {
	// 	await expect(crowdfund.processFundRound(forum.address)).revertedWith(
	// 		'MembersMissing()'
	// 	);
	// });

	// it('Should revert if non group member taking part', async function () {
	// 	await expect(
	// 		crowdfund
	// 			.connect(bob)
	// 			.submitFundContribution(forum.address, { value: getBigNumber(50) })
	// 	).revertedWith('NotMember()');
	// });
	// it('Should revert if user is depositing twice', async function () {
	// 	await expect(
	// 		crowdfund
	// 			.connect(proposer)
	// 			.submitFundContribution(forum.address, { value: getBigNumber(50) })
	// 	).revertedWith('IncorrectContribution()');
	// });
	// it('Should cancel round only if cancelled by proposer or dao, and return funds', async function () {
	// 	await expect(
	// 		crowdfund.connect(alice).cancelFundRound(forum.address)
	// 	).revertedWith('NotProposer()');

	// 	await crowdfund.connect(proposer).cancelFundRound(forum.address);

	// 	const deletedFund = await crowdfund.getFund(forum.address);
	// 	expect(deletedFund.individualContribution).to.equal(getBigNumber(0));
	// 	expect(deletedFund.valueNumerator).to.equal(getBigNumber(0));
	// 	expect(deletedFund.valueDenominator).to.equal(getBigNumber(0));
	// });
})

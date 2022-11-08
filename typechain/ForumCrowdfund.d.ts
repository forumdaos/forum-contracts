/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */

import {
  ethers,
  EventFilter,
  Signer,
  BigNumber,
  BigNumberish,
  PopulatedTransaction,
  BaseContract,
  ContractTransaction,
  Overrides,
  PayableOverrides,
  CallOverrides,
} from "ethers";
import { BytesLike } from "@ethersproject/bytes";
import { Listener, Provider } from "@ethersproject/providers";
import { FunctionFragment, EventFragment, Result } from "@ethersproject/abi";
import type { TypedEventFilter, TypedEvent, TypedListener } from "./common";

interface ForumCrowdfundInterface extends ethers.utils.Interface {
  functions: {
    "cancelCrowdfund(bytes32)": FunctionFragment;
    "contributionTracker(address,address)": FunctionFragment;
    "forumFactory()": FunctionFragment;
    "getCrowdfund(bytes32)": FunctionFragment;
    "initiateCrowdfund((address,uint256,uint32,string,string,bytes))": FunctionFragment;
    "processCrowdfund(bytes32)": FunctionFragment;
    "submitContribution(bytes32)": FunctionFragment;
  };

  encodeFunctionData(
    functionFragment: "cancelCrowdfund",
    values: [BytesLike]
  ): string;
  encodeFunctionData(
    functionFragment: "contributionTracker",
    values: [string, string]
  ): string;
  encodeFunctionData(
    functionFragment: "forumFactory",
    values?: undefined
  ): string;
  encodeFunctionData(
    functionFragment: "getCrowdfund",
    values: [BytesLike]
  ): string;
  encodeFunctionData(
    functionFragment: "initiateCrowdfund",
    values: [
      {
        targetContract: string;
        targetPrice: BigNumberish;
        deadline: BigNumberish;
        groupName: string;
        symbol: string;
        payload: BytesLike;
      }
    ]
  ): string;
  encodeFunctionData(
    functionFragment: "processCrowdfund",
    values: [BytesLike]
  ): string;
  encodeFunctionData(
    functionFragment: "submitContribution",
    values: [BytesLike]
  ): string;

  decodeFunctionResult(
    functionFragment: "cancelCrowdfund",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "contributionTracker",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "forumFactory",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "getCrowdfund",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "initiateCrowdfund",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "processCrowdfund",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "submitContribution",
    data: BytesLike
  ): Result;

  events: {
    "Cancelled(string)": EventFragment;
    "FundsAdded(string,address,uint256)": EventFragment;
    "NewCrowdfund(string)": EventFragment;
    "Processed(string,address)": EventFragment;
  };

  getEvent(nameOrSignatureOrTopic: "Cancelled"): EventFragment;
  getEvent(nameOrSignatureOrTopic: "FundsAdded"): EventFragment;
  getEvent(nameOrSignatureOrTopic: "NewCrowdfund"): EventFragment;
  getEvent(nameOrSignatureOrTopic: "Processed"): EventFragment;
}

export type CancelledEvent = TypedEvent<[string] & { groupName: string }>;

export type FundsAddedEvent = TypedEvent<
  [string, string, BigNumber] & {
    groupName: string;
    contributor: string;
    contribution: BigNumber;
  }
>;

export type NewCrowdfundEvent = TypedEvent<[string] & { groupName: string }>;

export type ProcessedEvent = TypedEvent<
  [string, string] & { groupName: string; groupAddress: string }
>;

export class ForumCrowdfund extends BaseContract {
  connect(signerOrProvider: Signer | Provider | string): this;
  attach(addressOrName: string): this;
  deployed(): Promise<this>;

  listeners<EventArgsArray extends Array<any>, EventArgsObject>(
    eventFilter?: TypedEventFilter<EventArgsArray, EventArgsObject>
  ): Array<TypedListener<EventArgsArray, EventArgsObject>>;
  off<EventArgsArray extends Array<any>, EventArgsObject>(
    eventFilter: TypedEventFilter<EventArgsArray, EventArgsObject>,
    listener: TypedListener<EventArgsArray, EventArgsObject>
  ): this;
  on<EventArgsArray extends Array<any>, EventArgsObject>(
    eventFilter: TypedEventFilter<EventArgsArray, EventArgsObject>,
    listener: TypedListener<EventArgsArray, EventArgsObject>
  ): this;
  once<EventArgsArray extends Array<any>, EventArgsObject>(
    eventFilter: TypedEventFilter<EventArgsArray, EventArgsObject>,
    listener: TypedListener<EventArgsArray, EventArgsObject>
  ): this;
  removeListener<EventArgsArray extends Array<any>, EventArgsObject>(
    eventFilter: TypedEventFilter<EventArgsArray, EventArgsObject>,
    listener: TypedListener<EventArgsArray, EventArgsObject>
  ): this;
  removeAllListeners<EventArgsArray extends Array<any>, EventArgsObject>(
    eventFilter: TypedEventFilter<EventArgsArray, EventArgsObject>
  ): this;

  listeners(eventName?: string): Array<Listener>;
  off(eventName: string, listener: Listener): this;
  on(eventName: string, listener: Listener): this;
  once(eventName: string, listener: Listener): this;
  removeListener(eventName: string, listener: Listener): this;
  removeAllListeners(eventName?: string): this;

  queryFilter<EventArgsArray extends Array<any>, EventArgsObject>(
    event: TypedEventFilter<EventArgsArray, EventArgsObject>,
    fromBlockOrBlockhash?: string | number | undefined,
    toBlock?: string | number | undefined
  ): Promise<Array<TypedEvent<EventArgsArray & EventArgsObject>>>;

  interface: ForumCrowdfundInterface;

  functions: {
    cancelCrowdfund(
      groupNameHash: BytesLike,
      overrides?: Overrides & { from?: string | Promise<string> }
    ): Promise<ContractTransaction>;

    contributionTracker(
      arg0: string,
      arg1: string,
      overrides?: CallOverrides
    ): Promise<[boolean]>;

    forumFactory(overrides?: CallOverrides): Promise<[string]>;

    getCrowdfund(
      groupNameHash: BytesLike,
      overrides?: CallOverrides
    ): Promise<
      [
        [string, BigNumber, number, string, string, string] & {
          targetContract: string;
          targetPrice: BigNumber;
          deadline: number;
          groupName: string;
          symbol: string;
          payload: string;
        },
        string[],
        BigNumber[]
      ] & {
        details: [string, BigNumber, number, string, string, string] & {
          targetContract: string;
          targetPrice: BigNumber;
          deadline: number;
          groupName: string;
          symbol: string;
          payload: string;
        };
        contributors: string[];
        contributions: BigNumber[];
      }
    >;

    initiateCrowdfund(
      parameters: {
        targetContract: string;
        targetPrice: BigNumberish;
        deadline: BigNumberish;
        groupName: string;
        symbol: string;
        payload: BytesLike;
      },
      overrides?: PayableOverrides & { from?: string | Promise<string> }
    ): Promise<ContractTransaction>;

    processCrowdfund(
      groupNameHash: BytesLike,
      overrides?: Overrides & { from?: string | Promise<string> }
    ): Promise<ContractTransaction>;

    submitContribution(
      groupNameHash: BytesLike,
      overrides?: PayableOverrides & { from?: string | Promise<string> }
    ): Promise<ContractTransaction>;
  };

  cancelCrowdfund(
    groupNameHash: BytesLike,
    overrides?: Overrides & { from?: string | Promise<string> }
  ): Promise<ContractTransaction>;

  contributionTracker(
    arg0: string,
    arg1: string,
    overrides?: CallOverrides
  ): Promise<boolean>;

  forumFactory(overrides?: CallOverrides): Promise<string>;

  getCrowdfund(
    groupNameHash: BytesLike,
    overrides?: CallOverrides
  ): Promise<
    [
      [string, BigNumber, number, string, string, string] & {
        targetContract: string;
        targetPrice: BigNumber;
        deadline: number;
        groupName: string;
        symbol: string;
        payload: string;
      },
      string[],
      BigNumber[]
    ] & {
      details: [string, BigNumber, number, string, string, string] & {
        targetContract: string;
        targetPrice: BigNumber;
        deadline: number;
        groupName: string;
        symbol: string;
        payload: string;
      };
      contributors: string[];
      contributions: BigNumber[];
    }
  >;

  initiateCrowdfund(
    parameters: {
      targetContract: string;
      targetPrice: BigNumberish;
      deadline: BigNumberish;
      groupName: string;
      symbol: string;
      payload: BytesLike;
    },
    overrides?: PayableOverrides & { from?: string | Promise<string> }
  ): Promise<ContractTransaction>;

  processCrowdfund(
    groupNameHash: BytesLike,
    overrides?: Overrides & { from?: string | Promise<string> }
  ): Promise<ContractTransaction>;

  submitContribution(
    groupNameHash: BytesLike,
    overrides?: PayableOverrides & { from?: string | Promise<string> }
  ): Promise<ContractTransaction>;

  callStatic: {
    cancelCrowdfund(
      groupNameHash: BytesLike,
      overrides?: CallOverrides
    ): Promise<void>;

    contributionTracker(
      arg0: string,
      arg1: string,
      overrides?: CallOverrides
    ): Promise<boolean>;

    forumFactory(overrides?: CallOverrides): Promise<string>;

    getCrowdfund(
      groupNameHash: BytesLike,
      overrides?: CallOverrides
    ): Promise<
      [
        [string, BigNumber, number, string, string, string] & {
          targetContract: string;
          targetPrice: BigNumber;
          deadline: number;
          groupName: string;
          symbol: string;
          payload: string;
        },
        string[],
        BigNumber[]
      ] & {
        details: [string, BigNumber, number, string, string, string] & {
          targetContract: string;
          targetPrice: BigNumber;
          deadline: number;
          groupName: string;
          symbol: string;
          payload: string;
        };
        contributors: string[];
        contributions: BigNumber[];
      }
    >;

    initiateCrowdfund(
      parameters: {
        targetContract: string;
        targetPrice: BigNumberish;
        deadline: BigNumberish;
        groupName: string;
        symbol: string;
        payload: BytesLike;
      },
      overrides?: CallOverrides
    ): Promise<void>;

    processCrowdfund(
      groupNameHash: BytesLike,
      overrides?: CallOverrides
    ): Promise<void>;

    submitContribution(
      groupNameHash: BytesLike,
      overrides?: CallOverrides
    ): Promise<void>;
  };

  filters: {
    "Cancelled(string)"(
      groupName?: string | null
    ): TypedEventFilter<[string], { groupName: string }>;

    Cancelled(
      groupName?: string | null
    ): TypedEventFilter<[string], { groupName: string }>;

    "FundsAdded(string,address,uint256)"(
      groupName?: string | null,
      contributor?: null,
      contribution?: null
    ): TypedEventFilter<
      [string, string, BigNumber],
      { groupName: string; contributor: string; contribution: BigNumber }
    >;

    FundsAdded(
      groupName?: string | null,
      contributor?: null,
      contribution?: null
    ): TypedEventFilter<
      [string, string, BigNumber],
      { groupName: string; contributor: string; contribution: BigNumber }
    >;

    "NewCrowdfund(string)"(
      groupName?: string | null
    ): TypedEventFilter<[string], { groupName: string }>;

    NewCrowdfund(
      groupName?: string | null
    ): TypedEventFilter<[string], { groupName: string }>;

    "Processed(string,address)"(
      groupName?: string | null,
      groupAddress?: string | null
    ): TypedEventFilter<
      [string, string],
      { groupName: string; groupAddress: string }
    >;

    Processed(
      groupName?: string | null,
      groupAddress?: string | null
    ): TypedEventFilter<
      [string, string],
      { groupName: string; groupAddress: string }
    >;
  };

  estimateGas: {
    cancelCrowdfund(
      groupNameHash: BytesLike,
      overrides?: Overrides & { from?: string | Promise<string> }
    ): Promise<BigNumber>;

    contributionTracker(
      arg0: string,
      arg1: string,
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    forumFactory(overrides?: CallOverrides): Promise<BigNumber>;

    getCrowdfund(
      groupNameHash: BytesLike,
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    initiateCrowdfund(
      parameters: {
        targetContract: string;
        targetPrice: BigNumberish;
        deadline: BigNumberish;
        groupName: string;
        symbol: string;
        payload: BytesLike;
      },
      overrides?: PayableOverrides & { from?: string | Promise<string> }
    ): Promise<BigNumber>;

    processCrowdfund(
      groupNameHash: BytesLike,
      overrides?: Overrides & { from?: string | Promise<string> }
    ): Promise<BigNumber>;

    submitContribution(
      groupNameHash: BytesLike,
      overrides?: PayableOverrides & { from?: string | Promise<string> }
    ): Promise<BigNumber>;
  };

  populateTransaction: {
    cancelCrowdfund(
      groupNameHash: BytesLike,
      overrides?: Overrides & { from?: string | Promise<string> }
    ): Promise<PopulatedTransaction>;

    contributionTracker(
      arg0: string,
      arg1: string,
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;

    forumFactory(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    getCrowdfund(
      groupNameHash: BytesLike,
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;

    initiateCrowdfund(
      parameters: {
        targetContract: string;
        targetPrice: BigNumberish;
        deadline: BigNumberish;
        groupName: string;
        symbol: string;
        payload: BytesLike;
      },
      overrides?: PayableOverrides & { from?: string | Promise<string> }
    ): Promise<PopulatedTransaction>;

    processCrowdfund(
      groupNameHash: BytesLike,
      overrides?: Overrides & { from?: string | Promise<string> }
    ): Promise<PopulatedTransaction>;

    submitContribution(
      groupNameHash: BytesLike,
      overrides?: PayableOverrides & { from?: string | Promise<string> }
    ): Promise<PopulatedTransaction>;
  };
}

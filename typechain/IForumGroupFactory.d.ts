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
  PayableOverrides,
  CallOverrides,
} from "ethers";
import { BytesLike } from "@ethersproject/bytes";
import { Listener, Provider } from "@ethersproject/providers";
import { FunctionFragment, EventFragment, Result } from "@ethersproject/abi";
import type { TypedEventFilter, TypedEvent, TypedListener } from "./common";

interface IForumGroupFactoryInterface extends ethers.utils.Interface {
  functions: {
    "deployGroup(string,string,address[],uint32[4],address[])": FunctionFragment;
  };

  encodeFunctionData(
    functionFragment: "deployGroup",
    values: [
      string,
      string,
      string[],
      [BigNumberish, BigNumberish, BigNumberish, BigNumberish],
      string[]
    ]
  ): string;

  decodeFunctionResult(
    functionFragment: "deployGroup",
    data: BytesLike
  ): Result;

  events: {};
}

export class IForumGroupFactory extends BaseContract {
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

  interface: IForumGroupFactoryInterface;

  functions: {
    deployGroup(
      name_: string,
      symbol_: string,
      voters_: string[],
      govSettings_: [BigNumberish, BigNumberish, BigNumberish, BigNumberish],
      customExtensions_: string[],
      overrides?: PayableOverrides & { from?: string | Promise<string> }
    ): Promise<ContractTransaction>;
  };

  deployGroup(
    name_: string,
    symbol_: string,
    voters_: string[],
    govSettings_: [BigNumberish, BigNumberish, BigNumberish, BigNumberish],
    customExtensions_: string[],
    overrides?: PayableOverrides & { from?: string | Promise<string> }
  ): Promise<ContractTransaction>;

  callStatic: {
    deployGroup(
      name_: string,
      symbol_: string,
      voters_: string[],
      govSettings_: [BigNumberish, BigNumberish, BigNumberish, BigNumberish],
      customExtensions_: string[],
      overrides?: CallOverrides
    ): Promise<string>;
  };

  filters: {};

  estimateGas: {
    deployGroup(
      name_: string,
      symbol_: string,
      voters_: string[],
      govSettings_: [BigNumberish, BigNumberish, BigNumberish, BigNumberish],
      customExtensions_: string[],
      overrides?: PayableOverrides & { from?: string | Promise<string> }
    ): Promise<BigNumber>;
  };

  populateTransaction: {
    deployGroup(
      name_: string,
      symbol_: string,
      voters_: string[],
      govSettings_: [BigNumberish, BigNumberish, BigNumberish, BigNumberish],
      customExtensions_: string[],
      overrides?: PayableOverrides & { from?: string | Promise<string> }
    ): Promise<PopulatedTransaction>;
  };
}

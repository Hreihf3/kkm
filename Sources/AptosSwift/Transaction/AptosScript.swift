//
//  AptosScript.swift
//  
//
//  Created by mathwallet on 2022/8/9.
//

import Foundation

public struct AptosScript {
    public let code: Data
    public let typeArgs: [AptosTypeTag]
    public let args: [AptosTransactionArgument]
    
    /// Scripts contain the Move bytecodes payload that can be submitted to Aptos chain for execution.
    /// - Parameters:
    ///   - code: Move bytecode
    ///   - typeArgs: Type arguments that bytecode requires.
    ///   - args: Arugments to bytecode function.
    ///   @example
    ///     A coin transfer function has one type argument "CoinType".
    ///     ```
    ///     public(script) fun transfer<CoinType>(from: &signer, to: address, amount: u64,)
    ///     ```
    /// - Returns: Aptos Script
    public init(code: Data, typeArgs: [AptosTypeTag], args: [AptosTransactionArgument]) {
        self.code = code
        self.typeArgs = typeArgs
        self.args = args
    }
}

extension AptosScript: BorshCodable {
    public init(from reader: inout BinaryReader) throws {
        self.code = try VarData.init(from: &reader).data
        self.typeArgs = try .init(from: &reader)
        self.args = try .init(from: &reader)
    }
    
    public func serialize(to writer: inout Data) throws {
        try VarData(code).serialize(to: &writer)
        try typeArgs.serialize(to: &writer)
        try args.serialize(to: &writer)
    }
}

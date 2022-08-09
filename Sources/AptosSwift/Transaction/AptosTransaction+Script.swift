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

public struct AptosScriptFunction {
    public let moduleName: AptosModuleId
    public let functionName: AptosIdentifier
    public let typeArgs: [AptosTypeTag]
    public let args: [Data]
    
    /// Scripts contain the Move bytecodes payload that can be submitted to Aptos chain for execution.
    /// - Parameters:
    ///   - moduleName: Fully qualified module name in format "AccountAddress::module_name" e.g. "0x1::coin"
    ///   - functionName: Function name
    ///   - typeArgs: Type arguments that move function requires..
    ///   - args: Arugments to the move function.
    ///   @example
    ///     A coin transfer function has three arugments "from", "to" and "amount".
    ///     ```
    ///     public(script) fun transfer<CoinType>(from: &signer, to: address, amount: u64,)
    ///     ```
    /// - Returns: Aptos ScriptFunction
    public init(moduleName: AptosModuleId, functionName: AptosIdentifier, typeArgs: [AptosTypeTag], args: [Data]) {
        self.moduleName = moduleName
        self.functionName = functionName
        self.typeArgs = typeArgs
        self.args = args
    }
    
    public static func natural(module: String, func: String, typeArgs: [AptosTypeTag], args: [Data]) throws -> Self {
        return AptosScriptFunction(moduleName: try AptosModuleId.fromString(module),
                                   functionName: AptosIdentifier(`func`),
                                   typeArgs: typeArgs,
                                   args: args)
    }
}

extension AptosScriptFunction {
    public init(from reader: inout BinaryReader) throws {
        self.moduleName = try .init(from: &reader)
        self.functionName = try .init(from: &reader)
        self.typeArgs = try .init(from: &reader)
        self.args = (try [VarData].init(from: &reader)).map({$0.data})
    }
    
    public func serialize(to writer: inout Data) throws {
        try moduleName.serialize(to: &writer)
        try functionName.serialize(to: &writer)
        try typeArgs.serialize(to: &writer)
        try args.map({VarData($0)}).serialize(to: &writer)
    }
}

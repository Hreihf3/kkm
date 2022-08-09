//
//  TransactionPayload.swift
//  
//
//  Created by xgblin on 2022/8/9.
//

import Foundation
import CryptoSwift

public protocol Payload {}

public struct ScriptFunctionPayload:Payload {
    public let moduleName: String
    public let functionName: String
    public let tyArgs: [String]
    public let args: [String]
    
    public init(moduleName: String, functionName:String, tyArgs: [String], args: [String]) {
        self.moduleName = moduleName
        self.functionName = functionName
        self.tyArgs = tyArgs
        self.args = args
    }
}

extension ScriptFunctionPayload:HumanReadable {
    public func toHuman() -> Any {
        return [
            "module_name": moduleName,
            "function_name": functionName,
            "ty_args": tyArgs,
            "args":args
        ]
    }
}

extension ScriptFunctionPayload:BorshCodable {
    public func serialize(to writer: inout Data) throws {
        try UInt128(3).serialize(to: &writer)
        try moduleName.serialize(to: &writer)
        try functionName.serialize(to: &writer)
        try tyArgs.serialize(to: &writer)
        try args.serialize(to: &writer)
    }

    public init(from reader: inout BinaryReader) throws {
        self.moduleName = try .init(from: &reader)
        self.functionName = try .init(from: &reader)
        self.tyArgs = try .init(from: &reader)
        self.args = try .init(from: &reader)
    }
}

public enum TransactionPayload {
    case scriptFunction(ScriptFunctionPayload)
    public var rawValue: UInt8 {
        switch self {
        case .scriptFunction: return 3
        }
    }
    
    public var name: String {
        switch self {
        case .scriptFunction: return "Script Function"
        }
    }
}

extension TransactionPayload:HumanReadable {
    public func toHuman() -> Any {
        var readable: [String: Any] = [
            "name": self.name
        ]
        switch self {
        case .scriptFunction(let scriptFunctionPayload):
            readable["value"] = scriptFunctionPayload.toHuman()
        }
    }
}

extension TransactionPayload: BorshCodable {
    public func serialize(to writer: inout Data) throws {
        try rawValue.serialize(to: &writer)
        switch self {
        case .scriptFunction(let payload): try payload.serialize(to: &writer)
        }
    }
    
    public init(from reader: inout BinaryReader) throws {
        let rawValue = try UInt8.init(from: &reader)
        switch rawValue {
        case 3: self = .scriptFunction(try ScriptFunctionPayload(from: &reader))
        default: fatalError()
        }
    }
}

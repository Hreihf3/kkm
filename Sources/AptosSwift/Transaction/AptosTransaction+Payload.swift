//
//  AptosTransaction+Payload.swift
//  
//
//  Created by mathwallet on 2022/8/9.
//

import Foundation

public enum AptosTransactionPayload {
    case WriteSet(AptosTransactionPayloadWriteSet)
    case Script(AptosTransactionPayloadScript)
    case ModuleBundle(AptosTransactionPayloadModuleBundle)
    case ScriptFunction(AptosTransactionPayloadScriptFunction)
    case Unknown
}

extension AptosTransactionPayload: BorshCodable {
    public func serialize(to writer: inout Data) throws {
        switch self {
        case .WriteSet(let paylaod):
            try UVarInt(0).serialize(to: &writer)
            try paylaod.serialize(to: &writer)
        case .Script(let paylaod):
            try UVarInt(1).serialize(to: &writer)
            try paylaod.serialize(to: &writer)
        case .ModuleBundle(let paylaod):
            try UVarInt(2).serialize(to: &writer)
            try paylaod.serialize(to: &writer)
        case .ScriptFunction(let paylaod):
            try UVarInt(3).serialize(to: &writer)
            try paylaod.serialize(to: &writer)
        case .Unknown:
            throw AptosError.serializeError
        }
    }
    
    public init(from reader: inout BinaryReader) throws {
        let index = try UVarInt.init(from: &reader).value
        switch index {
        case 0: self = .WriteSet(try AptosTransactionPayloadWriteSet(from: &reader))
        case 1: self = .Script(try AptosTransactionPayloadScript(from: &reader))
        case 2: self = .ModuleBundle(try AptosTransactionPayloadModuleBundle(from: &reader))
        case 3: self = .ScriptFunction(try AptosTransactionPayloadScriptFunction(from: &reader))
        default: throw AptosError.decodingError
        }
    }
}

public struct AptosTransactionPayloadWriteSet: BorshCodable {
    public init(from reader: inout BinaryReader) throws {
        throw AptosError.decodingError
    }
    
    public func serialize(to writer: inout Data) throws {
        throw AptosError.serializeError
    }
}

public struct AptosTransactionPayloadScript: BorshCodable {
    public let value: AptosScript
    
    public init(value: AptosScript) {
        self.value = value
    }
    
    public init(from reader: inout BinaryReader) throws {
        self.value = try .init(from: &reader)
    }
    
    public func serialize(to writer: inout Data) throws {
        try self.value.serialize(to: &writer)
    }
}

public struct AptosTransactionPayloadModuleBundle: BorshCodable {
    public let value: AptosModuleBundle
    
    public init(value: AptosModuleBundle) {
        self.value = value
    }
    
    public init(from reader: inout BinaryReader) throws {
        self.value = try .init(from: &reader)
    }
    
    public func serialize(to writer: inout Data) throws {
        try self.value.serialize(to: &writer)
    }
}

public struct AptosTransactionPayloadScriptFunction: BorshCodable {
    public let value: AptosScriptFunction
    
    public init(value: AptosScriptFunction) {
        self.value = value
    }
    
    public init(from reader: inout BinaryReader) throws {
        self.value = try .init(from: &reader)
    }
    
    public func serialize(to writer: inout Data) throws {
        try self.value.serialize(to: &writer)
    }
}

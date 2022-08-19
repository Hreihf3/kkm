//
//  AptosTransaction+Payload.swift
//  
//
//  Created by mathwallet on 2022/8/9.
//

import Foundation

public enum AptosTransactionPayload {
    case Script(AptosTransactionPayloadScript)
    case ModuleBundle(AptosTransactionPayloadModuleBundle)
    case EntryFunction(AptosTransactionPayloadEntryFunction)
    case Unknown
}

extension AptosTransactionPayload: BorshCodable {
    public func serialize(to writer: inout Data) throws {
        switch self {
        case .Script(let paylaod):
            try UVarInt(0).serialize(to: &writer)
            try paylaod.serialize(to: &writer)
        case .ModuleBundle(let paylaod):
            try UVarInt(1).serialize(to: &writer)
            try paylaod.serialize(to: &writer)
        case .EntryFunction(let paylaod):
            try UVarInt(2).serialize(to: &writer)
            try paylaod.serialize(to: &writer)
        case .Unknown:
            throw AptosError.serializeError
        }
    }
    
    public init(from reader: inout BinaryReader) throws {
        let index = try UVarInt.init(from: &reader).value
        switch index {
        case 0: self = .Script(try AptosTransactionPayloadScript(from: &reader))
        case 1: self = .ModuleBundle(try AptosTransactionPayloadModuleBundle(from: &reader))
        case 2: self = .EntryFunction(try AptosTransactionPayloadEntryFunction(from: &reader))
        default: throw AptosError.otherEror("Unknown variant index for TransactionPayload: \(index)")
        }
    }
}

public struct AptosTransactionPayloadWriteSet: BorshCodable {
    public init(from reader: inout BinaryReader) throws {
        throw AptosError.deserializeError
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

public struct AptosTransactionPayloadEntryFunction: BorshCodable {
    public let value: AptosEntryFunction
    
    public init(value: AptosEntryFunction) {
        self.value = value
    }
    
    public init(from reader: inout BinaryReader) throws {
        self.value = try .init(from: &reader)
    }
    
    public func serialize(to writer: inout Data) throws {
        try self.value.serialize(to: &writer)
    }
}

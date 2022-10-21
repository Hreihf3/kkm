//
//  AptosScriptABI.swift
//  
//
//  Created by mathwallet on 2022/10/20.
//

import Foundation

public struct AptosArgumentABI: BorshCodable {
    public let name: String
    public let typeTag: AptosTypeTag
    
    public init(name: String, typeTag: AptosTypeTag) {
        self.name = name
        self.typeTag = typeTag
    }
    
    public init(from reader: inout BinaryReader) throws {
        self.name = try .init(from: &reader)
        self.typeTag = try .init(from: &reader)
    }
    
    public func serialize(to writer: inout Data) throws {
        try self.name.serialize(to: &writer)
        try self.typeTag.serialize(to: &writer)
    }
}

public struct AptosTypeArgumentABI: BorshCodable {
    public let name: String
    
    public init(name: String) {
        self.name = name
    }
    
    public init(from reader: inout BinaryReader) throws {
        self.name = try .init(from: &reader)
    }
    
    public func serialize(to writer: inout Data) throws {
        try self.name.serialize(to: &writer)
    }
}

public enum AptosScriptABI {
    case TransactionScriptABI(AptosTransactionScriptABI)
    case EntryFunctionABI(AptosEntryFunctionABI)
    case Unknown
}

extension AptosScriptABI: BorshCodable {
    public func serialize(to writer: inout Data) throws {
        switch self {
        case .TransactionScriptABI(let paylaod):
            try UVarInt(0).serialize(to: &writer)
            try paylaod.serialize(to: &writer)
        case .EntryFunctionABI(let paylaod):
            try UVarInt(1).serialize(to: &writer)
            try paylaod.serialize(to: &writer)
        case .Unknown:
            throw AptosError.serializeError
        }
    }
    
    public init(from reader: inout BinaryReader) throws {
        let index = try UVarInt.init(from: &reader).value
        switch index {
        case 0: self = .TransactionScriptABI(try AptosTransactionScriptABI(from: &reader))
        case 1: self = .EntryFunctionABI(try AptosEntryFunctionABI(from: &reader))
        default: throw AptosError.otherEror("Unknown variant index for ScriptABI: \(index)")
        }
    }
}

public struct AptosTransactionScriptABI: BorshCodable {
    public let name: String
    public let doc: String
    public let code: Data
    public let typeArgs: [AptosTypeArgumentABI]
    public let args: [AptosArgumentABI]
    
    public init(name: String, doc: String, code: Data, typeArgs: [AptosTypeArgumentABI], args: [AptosArgumentABI]) {
        self.name = name
        self.doc = doc
        self.code = code
        self.typeArgs = typeArgs
        self.args = args
    }
    
    public init(from reader: inout BinaryReader) throws {
        self.name = try .init(from: &reader)
        self.doc = try .init(from: &reader)
        self.code = try VarData.init(from: &reader).data
        self.typeArgs = try .init(from: &reader)
        self.args = try .init(from: &reader)
    }
    
    public func serialize(to writer: inout Data) throws {
        try self.name.serialize(to: &writer)
        try self.doc.serialize(to: &writer)
        try VarData(self.code).serialize(to: &writer)
        try self.typeArgs.serialize(to: &writer)
        try self.args.serialize(to: &writer)
    }
}

public struct AptosEntryFunctionABI: BorshCodable {
    public let name: String
    public let moduleName: AptosModuleId
    public let doc: String
    public let typeArgs: [AptosTypeArgumentABI]
    public let args: [AptosArgumentABI]
    
    public init(name: String, moduleName: AptosModuleId, doc: String, typeArgs: [AptosTypeArgumentABI], args: [AptosArgumentABI]) {
        self.name = name
        self.moduleName = moduleName
        self.doc = doc
        self.typeArgs = typeArgs
        self.args = args
    }
    
    public init(from reader: inout BinaryReader) throws {
        self.name = try .init(from: &reader)
        self.moduleName = try .init(from: &reader)
        self.doc = try .init(from: &reader)
        self.typeArgs = try .init(from: &reader)
        self.args = try .init(from: &reader)
    }
    
    public func serialize(to writer: inout Data) throws {
        try self.name.serialize(to: &writer)
        try self.moduleName.serialize(to: &writer)
        try self.doc.serialize(to: &writer)
        try self.typeArgs.serialize(to: &writer)
        try self.args.serialize(to: &writer)
    }
}

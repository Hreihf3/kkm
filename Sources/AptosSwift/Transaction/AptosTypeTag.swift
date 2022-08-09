//
//  AptosTypeTag.swift
//  
//
//  Created by mathwallet on 2022/8/9.
//

import Foundation

public enum AptosTypeTag {
    case Bool
    case UInt8
    case UInt64
    case UInt128
    case Address
    case Signer
    case Data
    case Struct(AptosStructTag)
    case Unknown
}

extension AptosTypeTag: BorshCodable {
    public func serialize(to writer: inout Data) throws {
        switch self {
        case .Bool:
            try UVarInt(0).serialize(to: &writer)
        case .UInt8:
            try UVarInt(1).serialize(to: &writer)
        case .UInt64:
            try UVarInt(2).serialize(to: &writer)
        case .UInt128:
            try UVarInt(3).serialize(to: &writer)
        case .Address:
            try UVarInt(4).serialize(to: &writer)
        case .Signer:
            try UVarInt(5).serialize(to: &writer)
        case .Data:
            try UVarInt(6).serialize(to: &writer)
        case .Struct(let structTag):
            try UVarInt(7).serialize(to: &writer)
            try structTag.serialize(to: &writer)
        case .Unknown:
            throw AptosError.serializeError
        }
    }
    
    public init(from reader: inout BinaryReader) throws {
        let index = try UVarInt.init(from: &reader).value
        switch index {
        case 0: self = .Bool
        case 1: self = .UInt8
        case 2: self = .UInt64
        case 3: self = .UInt128
        case 4: self = .Address
        case 5: self = .Signer
        case 6: self = .Data
        case 7: self = .Struct(try AptosStructTag.init(from: &reader))
        default: throw AptosError.decodingError
        }
    }
}

public struct AptosStructTag: BorshCodable {
    public let address: AptosAddress
    public let moduleName: AptosIdentifier
    public let name: AptosIdentifier
    public let typeArgs: [AptosTypeTag]
    
    public init(address: AptosAddress, moduleName: AptosIdentifier, name: AptosIdentifier, typeArgs: [AptosTypeTag]) {
        self.address = address
        self.moduleName = moduleName
        self.name = name
        self.typeArgs = typeArgs
    }
    
    /// Converts a string literal to a StructTag
    /// - Parameter structTag: literal in format "AcountAddress::module_name::ResourceName", e.g. "0x1::aptos_coin::AptosCoin"
    /// - Returns: StructTag
    public static func fromString(_ structTag: String) throws -> Self {
        // Type args are not supported in string literal
        guard !structTag.contains("<") else {
            throw AptosError.otherEror("Not implemented")
        }
        
        let parts = structTag.components(separatedBy: "::")
        guard parts.count == 3 else {
            throw AptosError.otherEror("Invalid struct tag string literal.")
        }
        return AptosStructTag(address: try AptosAddress(parts[0]), moduleName: AptosIdentifier(parts[1]), name: AptosIdentifier(parts[2]), typeArgs: [])
    }
    
    public init(from reader: inout BinaryReader) throws {
        self.address = try .init(from: &reader)
        self.moduleName = try .init(from: &reader)
        self.name = try .init(from: &reader)
        self.typeArgs = try .init(from: &reader)
    }
    
    public func serialize(to writer: inout Data) throws {
        try address.serialize(to: &writer)
        try moduleName.serialize(to: &writer)
        try name.serialize(to: &writer)
        try typeArgs.serialize(to: &writer)
    }
}

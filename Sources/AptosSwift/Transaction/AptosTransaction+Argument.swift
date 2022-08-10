//
//  AptosTransactionArgument.swift
//  
//
//  Created by mathwallet on 2022/8/9.
//

import Foundation

public enum AptosTransactionArgument {
    case UInt8(AptosTransactionArgumentUInt8)
    case UInt64(AptosTransactionArgumentUInt64)
    case UInt128(AptosTransactionArgumentUInt128)
    case Address(AptosTransactionArgumentAddress)
    case Data(AptosTransactionArgumentData)
    case Bool(AptosTransactionArgumentBool)
    case Unknown
}

extension AptosTransactionArgument: BorshCodable {
    public func serialize(to writer: inout Data) throws {
        switch self {
        case .UInt8(let arg):
            try UVarInt(0).serialize(to: &writer)
            try arg.serialize(to: &writer)
        case .UInt64(let arg):
            try UVarInt(1).serialize(to: &writer)
            try arg.serialize(to: &writer)
        case .UInt128(let arg):
            try UVarInt(2).serialize(to: &writer)
            try arg.serialize(to: &writer)
        case .Address(let arg):
            try UVarInt(3).serialize(to: &writer)
            try arg.serialize(to: &writer)
        case .Data(let arg):
            try UVarInt(4).serialize(to: &writer)
            try arg.serialize(to: &writer)
        case .Bool(let arg):
            try UVarInt(5).serialize(to: &writer)
            try arg.serialize(to: &writer)
        case .Unknown:
            throw AptosError.serializeError
        }
    }
    
    public init(from reader: inout BinaryReader) throws {
        let index = try UVarInt.init(from: &reader).value
        switch index {
        case 0: self = .UInt8(try AptosTransactionArgumentUInt8(from: &reader))
        case 1: self = .UInt64(try AptosTransactionArgumentUInt64(from: &reader))
        case 2: self = .UInt128(try AptosTransactionArgumentUInt128(from: &reader))
        case 3: self = .Address(try AptosTransactionArgumentAddress(from: &reader))
        case 4: self = .Data(try AptosTransactionArgumentData(from: &reader))
        case 5: self = .Bool(try AptosTransactionArgumentBool(from: &reader))
        default: throw AptosError.otherEror("Unknown variant index for TransactionArgument: \(index)")
        }
    }
}

public struct AptosTransactionArgumentUInt8: BorshCodable {
    public let value: UInt8
    
    public init(_ value: UInt8) {
        self.value = value
    }
    
    public init(from reader: inout BinaryReader) throws {
        self.value = try .init(from: &reader)
    }
    
    public func serialize(to writer: inout Data) throws {
        try value.serialize(to: &writer)
    }
}

public struct AptosTransactionArgumentUInt64: BorshCodable {
    public let value: UInt64
    
    public init(_ value: UInt64) {
        self.value = value
    }
    
    public init(from reader: inout BinaryReader) throws {
        self.value = try .init(from: &reader)
    }
    
    public func serialize(to writer: inout Data) throws {
        try value.serialize(to: &writer)
    }
}

public struct AptosTransactionArgumentUInt128: BorshCodable {
    public let value: UInt128
    
    public init(_ value: UInt128) {
        self.value = value
    }
    
    public init(from reader: inout BinaryReader) throws {
        self.value = try .init(from: &reader)
    }
    
    public func serialize(to writer: inout Data) throws {
        try value.serialize(to: &writer)
    }
}

public struct AptosTransactionArgumentAddress: BorshCodable {
    public let value: AptosAddress
    
    public init(_ value: AptosAddress) {
        self.value = value
    }
    
    public init(from reader: inout BinaryReader) throws {
        self.value = try .init(from: &reader)
    }
    
    public func serialize(to writer: inout Data) throws {
        try value.serialize(to: &writer)
    }
}

public struct AptosTransactionArgumentData: BorshCodable {
    public let value: Data
    
    public init(_ value: Data) {
        self.value = value
    }
    
    public init(from reader: inout BinaryReader) throws {
        self.value = try VarData.init(from: &reader).data
    }
    
    public func serialize(to writer: inout Data) throws {
        try VarData(value).serialize(to: &writer)
    }
}

public struct AptosTransactionArgumentBool: BorshCodable {
    public let value: Bool
    
    public init(_ value: Bool) {
        self.value = value
    }
    
    public init(from reader: inout BinaryReader) throws {
        self.value = try .init(from: &reader)
    }
    
    public func serialize(to writer: inout Data) throws {
        try value.serialize(to: &writer)
    }
}

//
//  AptosModule.swift
//  
//
//  Created by mathwallet on 2022/8/9.
//

import Foundation

public struct AptosModule: BorshCodable {
    public let code: Data
    
    public init(code: Data) {
        self.code = code
    }
    
    public init(from reader: inout BinaryReader) throws {
        self.code = try VarData.init(from: &reader).data
    }
    
    public func serialize(to writer: inout Data) throws {
        try VarData(code).serialize(to: &writer)
    }
}

public struct AptosModuleBundle: BorshCodable {
    public let codes: [AptosModule]
    
    public init(codes: [AptosModule]) {
        self.codes = codes
    }
    
    public init(from reader: inout BinaryReader) throws {
        self.codes = try .init(from: &reader)
    }
    
    public func serialize(to writer: inout Data) throws {
        try codes.serialize(to: &writer)
    }
}

public struct AptosModuleId: BorshCodable {
    public let address: AptosAddress
    public let name: AptosIdentifier
    
    /// Converts a string literal to a ModuleId
    /// - Parameter moduleId: String literal in format "AccountAddress::module_name", e.g. "0x1::coin"
    /// - Returns: Aptos ModuleId
    public static func fromString(_ moduleId: String) throws -> Self {
        let parts = moduleId.components(separatedBy: "::")
        guard parts.count == 2 else {
            throw AptosError.otherEror("Invalid module id.")
        }
        return AptosModuleId(address: try AptosAddress(parts[0]), name: AptosIdentifier(parts[1]))
    }
    
    public init(address: AptosAddress, name: AptosIdentifier) {
        self.address = address
        self.name = name
    }
    
    public init(from reader: inout BinaryReader) throws {
        self.address = try .init(from: &reader)
        self.name = try .init(from: &reader)
    }
    
    public func serialize(to writer: inout Data) throws {
        try address.serialize(to: &writer)
        try name.serialize(to: &writer)
    }
}

//
//  AptosIdentifier.swift
//  
//
//  Created by mathwallet on 2022/8/9.
//

import Foundation

public struct AptosIdentifier {
    public let value: String
    
    public init(_ value: String) {
        self.value = value
    }
}

extension AptosIdentifier: BorshCodable {
    public init(from reader: inout BinaryReader) throws {
        self.value = try .init(from: &reader)
    }
    
    public func serialize(to writer: inout Data) throws {
        try self.value.serialize(to: &writer)
    }
}

//
//  AptosAddress.swift
//  
//
//  Created by mathwallet on 2022/8/8.
//

import Foundation

public struct AptosAddress {
    public static let SIZE: Int = 32
    
    public var data: Data
    public var address: String {
        return  self.data.toHexString().addHexPrefix()
    }
    
    public init(_ data: Data) throws {
        guard data.count <= AptosAddress.SIZE else {
            throw AptosError.keyError("Hex string is too long. Address's length is \(AptosAddress.SIZE) bytes.")
        }
        self.data = Data(repeating: 0, count: AptosAddress.SIZE - data.count) + data
    }
    
    public init(_ address: String) throws {
        try self.init(Data(hex: address.stripHexPrefix()))
    }
}

extension AptosAddress: BorshCodable {
    public func serialize(to writer: inout Data) throws {
        writer.append(data.bytes, count: AptosAddress.SIZE)
    }
    
    public init(from reader: inout BinaryReader) throws {
        self.data = Data(reader.read(count: UInt32(AptosAddress.SIZE)))
    }
}

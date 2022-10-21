//
//  AptosAddress.swift
//  
//
//  Created by mathwallet on 2022/8/8.
//

import Foundation

public struct AptosAddress: CustomStringConvertible {
    public static let SIZE: Int = 32
    
    public var data: Data
    public var address: String {
        return self.data.toHexString().addHexPrefix()
    }
    
    public var shortString: String {
        var shortString = self.address
        while shortString.hasPrefix("0x0") {
            shortString = shortString.replacingOccurrences(of: "0x0", with: "0x")
        }
        return shortString
    }
    
    public init(_ data: Data) throws {
        guard data.count <= AptosAddress.SIZE else {
            throw AptosError.keyError("Hex string is too long. Address's length is \(Self.SIZE) bytes.")
        }
        self.data = Data(repeating: 0, count: Self.SIZE - data.count) + data
    }
    
    public init(_ address: String) throws {
        let hex = address.stripHexPrefix()
        let prefix = hex.count % 2 == 0 ? "" : "0"
        try self.init(Data(hex: prefix + hex))
    }
    
    public var description: String {
        return shortString
    }
}

extension AptosAddress: BorshCodable {
    public func serialize(to writer: inout Data) throws {
        writer.append(data.bytes, count: Self.SIZE)
    }
    
    public init(from reader: inout BinaryReader) throws {
        self.data = Data(reader.read(count: UInt32(Self.SIZE)))
    }
}

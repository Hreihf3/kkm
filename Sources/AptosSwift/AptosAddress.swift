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
        var addressString = self.data.toHexString().addHexPrefix()
        while addressString.hasPrefix("0x0") {
            addressString = addressString.replacingOccurrences(of: "0x0", with: "0x")
        }
        return addressString
    }
    
    public init(_ data: Data) throws {
        guard data.count <= AptosAddress.SIZE else {
            throw AptosError.keyError("Hex string is too long. Address's length is \(Self.SIZE) bytes.")
        }
        self.data = Data(repeating: 0, count: Self.SIZE - data.count) + data
    }
    
    public init(_ address: String) throws {
        guard address.isHex() else {
            throw AptosError.keyError("Invalid address string. \(address)")
        }
        let hex = address.stripHexPrefix()
        let prefix = hex.count % 2 == 0 ? "" : "0"
        try self.init(Data(hex: prefix + hex))
    }
    
    public var description: String {
        return address
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

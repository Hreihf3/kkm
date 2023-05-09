//
//  BorshSerialize.swift
//  
//
//  Created by mathwallet on 2022/7/14.
//

import Foundation

public protocol BorshSerializable {
    func serialize(to writer: inout Data) throws
}


extension UInt8: BorshSerializable {}
extension UInt16: BorshSerializable {}
extension UInt32: BorshSerializable {}
extension UInt64: BorshSerializable {}
extension Int8: BorshSerializable {}
extension Int16: BorshSerializable {}
extension Int32: BorshSerializable {}
extension Int64: BorshSerializable {}

public extension FixedWidthInteger {
    func serialize(to writer: inout Data) throws {
        writer.append(contentsOf: withUnsafeBytes(of: self.littleEndian) { Array($0) })
    }
}

extension UInt2X: BorshSerializable {
    public func serialize(to writer: inout Data) throws {
        writer.append(contentsOf: withUnsafeBytes(of: self.littleEndian) { Array($0) })
    }
}

extension Int2X: BorshSerializable {
    public func serialize(to writer: inout Data) throws {
        writer.append(contentsOf: withUnsafeBytes(of: self.littleEndian) { Array($0) })
    }
}

extension UVarInt: BorshSerializable {
    public func serialize(to writer: inout Data) throws {
        var vui = [UInt8]()
        var val = self.value
        while val >= 128 {
            vui.append(UInt8(val % 128))
            val /= 128
        }
        vui.append(UInt8(val))

        for i in 0..<vui.count-1 {
            vui[i] += 128
        }
        writer.append(Data(vui))
    }
}

extension VarData: BorshSerializable {
    public func serialize(to writer: inout Data) throws {
        try UVarInt(self.data.count).serialize(to: &writer)
        writer.append(self.data)
    }
}

extension Bool: BorshSerializable {
    public func serialize(to writer: inout Data) throws {
        let intRepresentation: UInt8 = self ? 1 : 0
        try intRepresentation.serialize(to: &writer)
    }
}

extension String: BorshSerializable {
    public func serialize(to writer: inout Data) throws {
        let data = Data(utf8)
        try UVarInt(data.count).serialize(to: &writer)
        writer.append(data)
    }
}

extension Array: BorshSerializable where Element: BorshSerializable {
    public func serialize(to writer: inout Data) throws {
        try UVarInt(count).serialize(to: &writer)
        try forEach { try $0.serialize(to: &writer) }
    }
}

extension Set: BorshSerializable where Element: BorshSerializable & Comparable {
    public func serialize(to writer: inout Data) throws {
        try sorted().serialize(to: &writer)
    }
}

extension Dictionary: BorshSerializable where Key: BorshSerializable & Comparable, Value: BorshSerializable {
    public func serialize(to writer: inout Data) throws {
        let sortedByKeys = sorted(by: {$0.key < $1.key})
        try UVarInt(sortedByKeys.count).serialize(to: &writer)
        try sortedByKeys.forEach { key, value in
            try key.serialize(to: &writer)
            try value.serialize(to: &writer)
        }
    }
}

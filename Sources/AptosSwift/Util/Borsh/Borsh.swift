//
//  Borsh.swift
//  
//
//  Created by mathwallet on 2022/7/14.
//

import Foundation

public typealias BorshCodable = BorshSerializable & BorshDeserializable

public struct UVarInt {
    public let value: UInt32
    public init<T: FixedWidthInteger>(_ value: T) {
        self.value = UInt32(value)
    }
}

public struct VarData {
    public let data: Data
    public init(_ data: Data) {
        self.data = data
    }
}

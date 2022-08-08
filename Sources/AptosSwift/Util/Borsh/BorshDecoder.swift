//
//  BorshDecoder.swift
//  
//
//  Created by mathwallet on 2022/7/14.
//

import Foundation

public struct BorshDecoder {
    public init() {}
    public func decode<T>(_ type: T.Type, from data: Data) throws -> T where T : BorshDeserializable {
        var reader = BinaryReader(bytes: [UInt8](data))
        return try T.init(from: &reader)
    }
}

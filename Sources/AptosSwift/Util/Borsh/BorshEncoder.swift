//
//  BorshEncoder.swift
//  
//
//  Created by mathwallet on 2022/7/14.
//

import Foundation

public struct BorshEncoder {
    public init() {}
    public func encode<T>(_ value: T) throws -> Data where T : BorshSerializable {
        var writer = Data()
        try value.serialize(to: &writer)
        return writer
    }
}

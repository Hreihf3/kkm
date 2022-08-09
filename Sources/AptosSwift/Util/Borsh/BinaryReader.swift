//
//  BinaryReader.swift
//  
//
//  Created by mathwallet on 2022/7/14.
//

import Foundation

public struct BinaryReader {
    private var cursor: Int
    private var bytes: [UInt8]

    public init(bytes: [UInt8]) {
        self.cursor = 0
        self.bytes = bytes
    }
    
    func remainingBytes() -> [UInt8] {
        return Array(bytes[cursor..<bytes.count])
    }
}

extension BinaryReader {
    mutating func read(count: UInt32) -> [UInt8] {
        let newPosition = cursor + Int(count)
        let result = bytes[cursor..<newPosition]
        cursor = newPosition
        return Array(result)
    }
}

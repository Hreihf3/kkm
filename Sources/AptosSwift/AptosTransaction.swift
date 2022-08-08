//
//  AptosTransaction.swift
//  
//
//  Created by mathwallet on 2022/8/8.
//

import Foundation

public struct AptosTransaction {
    public let sender: AptosAddress
    public let sequenceNumber: UInt64
    public let maxGasAmount: UInt64
    public let gasUnitPrice: UInt64
    public let expirationTimestampSecs: UInt64
    public let chainId: UInt8
//    public let payload: Any
}

extension AptosTransaction: BorshCodable {
    public func serialize(to writer: inout Data) throws {
        try sender.serialize(to: &writer)
        try sequenceNumber.serialize(to: &writer)
        // try payload.serialize(to: &writer)
        try gasUnitPrice.serialize(to: &writer)
        try expirationTimestampSecs.serialize(to: &writer)
        try chainId.serialize(to: &writer)
    }
    
    public init(from reader: inout BinaryReader) throws {
        self.sender = try .init(from: &reader)
        self.sequenceNumber = try .init(from: &reader)
        self.maxGasAmount = try .init(from: &reader)
        self.gasUnitPrice = try .init(from: &reader)
        self.expirationTimestampSecs = try .init(from: &reader)
        self.chainId = try .init(from: &reader)
    }
}

public struct AptosSignedTransaction {
    public let transaction: AptosTransaction
    public let authenticator: AptosAuthenticator
}

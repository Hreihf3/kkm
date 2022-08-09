//
//  AptosTransaction.swift
//  
//
//  Created by mathwallet on 2022/8/8.
//

import Foundation
import CryptoSwift

public let RAW_TRANSACTION_SALT = "APTOS::RawTransaction"

public struct AptosRawTransaction {
    public let sender: AptosAddress
    public let sequenceNumber: UInt64
    public let maxGasAmount: UInt64
    public let gasUnitPrice: UInt64
    public let expirationTimestampSecs: UInt64
    public let chainId: UInt8
    public let payload: AptosTransactionPayload
    
    public init(sender: AptosAddress,
                sequenceNumber: UInt64,
                maxGasAmount: UInt64,
                gasUnitPrice: UInt64,
                expirationTimestampSecs: UInt64,
                chainId: UInt8,
                payload: AptosTransactionPayload) {
        self.sender = sender
        self.sequenceNumber = sequenceNumber
        self.maxGasAmount = maxGasAmount
        self.gasUnitPrice = gasUnitPrice
        self.expirationTimestampSecs = expirationTimestampSecs
        self.chainId = chainId
        self.payload = payload
    }
    
    public func sign(_ keyPair: AptosKeyPairEd25519) throws -> AptosSignedTransaction {
        var message = Data()
        message.append("APTOS::RawTransaction".data(using: .utf8)!.sha3(.sha256))
        
        try self.serialize(to: &message)
        
        let publicKey = keyPair.publicKey
        let sigData = try keyPair.signDigest(messageDigest: message)
        
        let authenticator = try AptosTransactionAuthenticatorEd25519(publicKey: publicKey,
                                                                     signature: AptosSignatureEd25519(sigData))
        return AptosSignedTransaction(transaction: self, authenticator: .Ed25519(authenticator))
    }
}

extension AptosRawTransaction: BorshCodable {
    public func serialize(to writer: inout Data) throws {
        try sender.serialize(to: &writer)
        try sequenceNumber.serialize(to: &writer)
        try payload.serialize(to: &writer)
        try maxGasAmount.serialize(to: &writer)
        try gasUnitPrice.serialize(to: &writer)
        try expirationTimestampSecs.serialize(to: &writer)
        try chainId.serialize(to: &writer)
    }
    
    public init(from reader: inout BinaryReader) throws {
        self.sender = try .init(from: &reader)
        self.sequenceNumber = try .init(from: &reader)
        self.payload = try .init(from: &reader)
        self.maxGasAmount = try .init(from: &reader)
        self.gasUnitPrice = try .init(from: &reader)
        self.expirationTimestampSecs = try .init(from: &reader)
        self.chainId = try .init(from: &reader)
    }
}

public struct AptosSignedTransaction {
    public let transaction: AptosRawTransaction
    public let authenticator: AptosTransactionAuthenticator
    
    public init(transaction: AptosRawTransaction, authenticator: AptosTransactionAuthenticator) {
        self.transaction = transaction
        self.authenticator = authenticator
    }
}

extension AptosSignedTransaction: BorshCodable {
    public func serialize(to writer: inout Data) throws {
        try transaction.serialize(to: &writer)
        try authenticator.serialize(to: &writer)
    }
    
    public init(from reader: inout BinaryReader) throws {
        self.transaction = try .init(from: &reader)
        self.authenticator = try .init(from: &reader)
    }
}

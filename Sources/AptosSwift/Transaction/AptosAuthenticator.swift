//
//  AptosAuthenticator.swift
//  
//
//  Created by mathwallet on 2022/8/8.
//

import Foundation


// MARK: - Account Authenticator

public enum AptosAccountAuthenticator {
    case Ed25519(AptosAcountAuthenticatorEd25519)
    case MultiEd25519(AptosAccountAuthenticatorMultiEd25519)
    case Unknown
}

extension AptosAccountAuthenticator: BorshCodable {
    public func serialize(to writer: inout Data) throws {
        switch self {
        case .Ed25519(let authenticator):
            try UVarInt(0).serialize(to: &writer)
            try authenticator.serialize(to: &writer)
        case .MultiEd25519(let authenticator):
            try UVarInt(1).serialize(to: &writer)
            try authenticator.serialize(to: &writer)
        case .Unknown:
            throw AptosError.serializeError
        }
    }
    
    public init(from reader: inout BinaryReader) throws {
        let index = try UVarInt.init(from: &reader).value
        switch index {
        case 0: self = .Ed25519(try AptosAcountAuthenticatorEd25519(from: &reader))
        case 1: self = .MultiEd25519(try AptosAccountAuthenticatorMultiEd25519(from: &reader))
        default: throw AptosError.decodingError
        }
    }
}

extension AptosAccountAuthenticator: Encodable {
    public func encode(to encoder: Encoder) throws {
        switch self {
        case .Ed25519(let aptosAcountAuthenticatorEd25519):
            try aptosAcountAuthenticatorEd25519.encode(to: encoder)
        case .MultiEd25519(let aptosAccountAuthenticatorMultiEd25519):
            try aptosAccountAuthenticatorMultiEd25519.encode(to: encoder)
        case .Unknown:
            throw AptosError.encodingError
        }
    }
}

public struct AptosAcountAuthenticatorEd25519: BorshCodable {
    public let publicKey: AptosPublicKeyEd25519
    public let signature: AptosSignatureEd25519
    
    public init(publicKey: AptosPublicKeyEd25519, signature: AptosSignatureEd25519) {
        self.publicKey = publicKey
        self.signature = signature
    }
    
    public func serialize(to writer: inout Data) throws {
        try publicKey.serialize(to: &writer)
        try signature.serialize(to: &writer)
    }
    
    public init(from reader: inout BinaryReader) throws {
        self.publicKey = try .init(from: &reader)
        self.signature = try .init(from: &reader)
    }
}

extension AptosAcountAuthenticatorEd25519: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode("ed25519_signature", forKey: .type)
        try container.encode(publicKey.hex, forKey: .publicKey)
        try container.encode(signature.hex, forKey: .signature)
    }
    
    public enum CodingKeys: String, CodingKey {
        case type = "type"
        case publicKey = "public_key"
        case signature = "signature"
    }
}


public struct AptosAccountAuthenticatorMultiEd25519: BorshCodable {
    public let publicKey: AptosMultiEd25519PublicKey
    public let signature: AptosMultiEd25519Signature
    
    public init(publicKey: AptosMultiEd25519PublicKey, signature: AptosMultiEd25519Signature) {
        self.publicKey = publicKey
        self.signature = signature
    }
    
    public func serialize(to writer: inout Data) throws {
        try publicKey.serialize(to: &writer)
        try signature.serialize(to: &writer)
    }
    
    public init(from reader: inout BinaryReader) throws {
        self.publicKey = try .init(from: &reader)
        self.signature = try .init(from: &reader)
    }
}

extension AptosAccountAuthenticatorMultiEd25519: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode("ed25519_signature", forKey: .type)
        try container.encode(publicKey.publicKeys.map{$0.hex}, forKey: .publicKey)
        try container.encode(signature.signatures.map{$0.hex}, forKey: .signature)
    }
    
    public enum CodingKeys: String, CodingKey {
        case type = "type"
        case publicKey = "public_key"
        case signature = "signature"
    }
}

// MARK: - Transaction Authenticator

public enum AptosTransactionAuthenticator {
    case Ed25519(AptosTransactionAuthenticatorEd25519)
    case MultiEd25519(AptosTransactionAuthenticatorMultiEd25519)
    case MultiAgent(AptosTransactionAuthenticatorMultiAgent)
    case Unknown
}

extension AptosTransactionAuthenticator: BorshCodable {
    public func serialize(to writer: inout Data) throws {
        switch self {
        case .Ed25519(let authenticator):
            try UVarInt(0).serialize(to: &writer)
            try authenticator.serialize(to: &writer)
        case .MultiEd25519(let authenticator):
            try UVarInt(1).serialize(to: &writer)
            try authenticator.serialize(to: &writer)
        case .MultiAgent(let authenticator):
            try UVarInt(2).serialize(to: &writer)
            try authenticator.serialize(to: &writer)
        case .Unknown:
            throw AptosError.serializeError
        }
    }
    
    public init(from reader: inout BinaryReader) throws {
        let index = try UVarInt.init(from: &reader).value
        switch index {
        case 0: self = .Ed25519(try AptosTransactionAuthenticatorEd25519(from: &reader))
        case 1: self = .MultiEd25519(try AptosTransactionAuthenticatorMultiEd25519(from: &reader))
        case 2: self = .MultiAgent(try AptosTransactionAuthenticatorMultiAgent(from: &reader))
        default: throw AptosError.decodingError
        }
    }
}

extension AptosTransactionAuthenticator: Encodable {
    public func encode(to encoder: Encoder) throws {
        switch self {
        case .Ed25519(let aptosTransactionAuthenticatorEd25519):
            try aptosTransactionAuthenticatorEd25519.encode(to: encoder)
        case .MultiEd25519(let aptosTransactionAuthenticatorMultiEd25519):
            try aptosTransactionAuthenticatorMultiEd25519.encode(to: encoder)
        default:
            throw AptosError.encodingError
        }
    }
}

public struct AptosTransactionAuthenticatorEd25519: BorshCodable {
    public let publicKey: AptosPublicKeyEd25519
    public let signature: AptosSignatureEd25519
    
    public init(publicKey: AptosPublicKeyEd25519, signature: AptosSignatureEd25519) {
        self.publicKey = publicKey
        self.signature = signature
    }
    
    public func serialize(to writer: inout Data) throws {
        try publicKey.serialize(to: &writer)
        try signature.serialize(to: &writer)
    }
    
    public init(from reader: inout BinaryReader) throws {
        self.publicKey = try .init(from: &reader)
        self.signature = try .init(from: &reader)
    }
}

extension AptosTransactionAuthenticatorEd25519: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode("ed25519_signature", forKey: .type)
        try container.encode(publicKey.hex, forKey: .publicKey)
        try container.encode(signature.hex, forKey: .signature)
    }
    
    public enum CodingKeys: String, CodingKey {
        case type = "type"
        case publicKey = "public_key"
        case signature = "signature"
    }
}

public struct AptosTransactionAuthenticatorMultiEd25519: BorshCodable {
    public let publicKey: AptosMultiEd25519PublicKey
    public let signature: AptosMultiEd25519Signature
    
    public init(publicKey: AptosMultiEd25519PublicKey, signature: AptosMultiEd25519Signature) {
        self.publicKey = publicKey
        self.signature = signature
    }
    
    public func serialize(to writer: inout Data) throws {
        try publicKey.serialize(to: &writer)
        try signature.serialize(to: &writer)
    }
    
    public init(from reader: inout BinaryReader) throws {
        self.publicKey = try .init(from: &reader)
        self.signature = try .init(from: &reader)
    }
}

extension AptosTransactionAuthenticatorMultiEd25519:Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode("ed25519_signature", forKey: .type)
        try container.encode(publicKey.publicKeys.map{$0.hex}, forKey: .publicKey)
        try container.encode(signature.signatures.map{$0.hex}, forKey: .signature)
    }
    
    public enum CodingKeys: String, CodingKey {
        case type = "type"
        case publicKey = "public_key"
        case signature = "signature"
    }
}

public struct AptosTransactionAuthenticatorMultiAgent: BorshCodable {
    public let sender: AptosAccountAuthenticator
    public let secondarySignerAddresses: [AptosAddress]
    public let secondarySigners: [AptosAccountAuthenticator]
    
    public init(sender: AptosAccountAuthenticator, secondarySignerAddresses: [AptosAddress], secondarySigners: [AptosAccountAuthenticator]) {
        self.sender = sender
        self.secondarySignerAddresses = secondarySignerAddresses
        self.secondarySigners = secondarySigners
    }
    
    public func serialize(to writer: inout Data) throws {
        try sender.serialize(to: &writer)
        try secondarySignerAddresses.serialize(to: &writer)
        try secondarySigners.serialize(to: &writer)
    }
    
    public init(from reader: inout BinaryReader) throws {
        self.sender = try .init(from: &reader)
        self.secondarySignerAddresses = try .init(from: &reader)
        self.secondarySigners = try .init(from: &reader)
    }
}

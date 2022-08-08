//
//  AptosAuthenticator.swift
//  
//
//  Created by mathwallet on 2022/8/8.
//

import Foundation

public enum AptosAuthenticator {
    case Ed25519(AptosAuthenticatorEd25519)
    case MultiEd25519
    case MultiAgent
    case Unknown
}

extension AptosAuthenticator: BorshCodable {
    public func serialize(to writer: inout Data) throws {
        switch self {
        case .Ed25519(let authenticator):
            try UVarInt(0).serialize(to: &writer)
            try authenticator.serialize(to: &writer)
        case .MultiEd25519:
            try UVarInt(1).serialize(to: &writer)
        case .MultiAgent:
            try UVarInt(2).serialize(to: &writer)
        case .Unknown:
            throw AptosError.serializeError
        }
    }
    
    public init(from reader: inout BinaryReader) throws {
        let index = try UVarInt.init(from: &reader).value
        switch index {
        case 0: self = .Ed25519(try AptosAuthenticatorEd25519(from: &reader))
        case 1: self = .MultiEd25519
        case 2: self = .MultiAgent
        default: throw AptosError.decodingError
        }
    }
}

public struct AptosAuthenticatorEd25519 {
    public let publicKey: AptosPublicKeyEd25519
    public let signature: AptosSignatureEd25519
    
    public init(publicKey: AptosPublicKeyEd25519, signature: AptosSignatureEd25519) {
        self.publicKey = publicKey
        self.signature = signature
    }
}

extension AptosAuthenticatorEd25519: BorshCodable {
    public func serialize(to writer: inout Data) throws {
        try publicKey.serialize(to: &writer)
        try signature.serialize(to: &writer)
    }
    
    public init(from reader: inout BinaryReader) throws {
        self.publicKey = try .init(from: &reader)
        self.signature = try .init(from: &reader)
    }
}
                                

public struct AptosAuthenticatorMultiEd25519 {
    public let publicKey: AptosPublicKeyEd25519
    public let signature: AptosSignatureEd25519
    
    public init(publicKey: AptosPublicKeyEd25519, signature: AptosSignatureEd25519) {
        self.publicKey = publicKey
        self.signature = signature
    }
}

extension AptosAuthenticatorMultiEd25519: BorshCodable {
    public func serialize(to writer: inout Data) throws {
        try publicKey.serialize(to: &writer)
        try signature.serialize(to: &writer)
    }
    
    public init(from reader: inout BinaryReader) throws {
        self.publicKey = try .init(from: &reader)
        self.signature = try .init(from: &reader)
    }
}

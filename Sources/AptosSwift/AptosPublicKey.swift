//
//  AptosPublicKey.swift
//  
//
//  Created by mathwallet on 2022/8/8.
//

import Foundation

public struct AptosPublicKeyEd25519 {
    public static let SIZE: Int = 32
    
    public let data: Data
    
    public init(_ data: Data) throws {
        guard data.count == AptosPublicKeyEd25519.SIZE else {
            throw AptosError.keyError("Public key length is \(AptosPublicKeyEd25519.SIZE) bytes.")
        }
        
        self.data = data
    }
}

extension AptosPublicKeyEd25519: BorshCodable {
    public func serialize(to writer: inout Data) throws {
        try VarData(data).serialize(to: &writer)
    }
    
    public init(from reader: inout BinaryReader) throws {
        self.data = try VarData.init(from: &reader).data
    }
}


public struct AptosMultiEd25519PublicKey {
    public static let MAX_SIGNATURES_SUPPORTED: UInt8 = 32
    
    public let publicKeys: [AptosPublicKeyEd25519]
    public let threshold: UInt8
    
    public init(publicKeys: [AptosPublicKeyEd25519], threshold: UInt8) throws {
        guard threshold > Self.MAX_SIGNATURES_SUPPORTED else {
            throw AptosError.keyError("Threshold cannot be larger than \(Self.MAX_SIGNATURES_SUPPORTED)")
        }
        
        self.publicKeys = publicKeys
        self.threshold = threshold
    }
}

extension AptosMultiEd25519PublicKey: BorshCodable {
    public func serialize(to writer: inout Data) throws {
        var data = Data()
        for pubKey in publicKeys {
            data.append(pubKey.data)
        }
        data.append(threshold)
        
        try VarData(data).serialize(to: &writer)
    }
    
    public init(from reader: inout BinaryReader) throws {
        let data = try VarData.init(from: &reader).data
        
        var pubKeys: [AptosPublicKeyEd25519] = []
        let count = (data.count - 1) / AptosPublicKeyEd25519.SIZE
        for i in 0..<count {
            let start = i * 32
            pubKeys.append(try AptosPublicKeyEd25519(data.subdata(in: start..<(start + 32))))
        }
        
        self.publicKeys = pubKeys
        self.threshold = data.bytes.last!
    }
}

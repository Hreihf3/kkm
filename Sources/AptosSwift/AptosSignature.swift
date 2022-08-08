//
//  AptosSignature.swift
//  
//
//  Created by mathwallet on 2022/8/8.
//

import Foundation

public struct AptosSignatureEd25519 {
    public static let SIZE: Int = 64
    
    public let data: Data
    
    public init(_ data: Data) throws {
        guard data.count == AptosPublicKeyEd25519.SIZE else {
            throw AptosError.keyError("Signature length is \(AptosSignatureEd25519.SIZE) bytes.")
        }
        
        self.data = data
    }
}

extension AptosSignatureEd25519: BorshCodable {
    public func serialize(to writer: inout Data) throws {
        try VarData(data).serialize(to: &writer)
    }
    
    public init(from reader: inout BinaryReader) throws {
        self.data = try VarData.init(from: &reader).data
    }
}


public struct AptosMultiEd25519Signature {
    public static let BITMAP_LEN: UInt8 = 4
    
    public let signatures: [AptosSignatureEd25519]
    public let bitmap: Data
    
    public init(signatures: [AptosSignatureEd25519], bitmap: Data) throws {
        guard bitmap.count == Self.BITMAP_LEN else {
            throw AptosError.keyError("Signature length is \(Self.BITMAP_LEN) bytes.")
        }
        
        self.signatures = signatures
        self.bitmap = bitmap
    }
}

extension AptosMultiEd25519Signature: BorshCodable {
    public func serialize(to writer: inout Data) throws {
//        try VarData(data).serialize(to: &writer)
    }
    
    public init(from reader: inout BinaryReader) throws {
        self.signatures = []
        self.bitmap = Data()
    }
}

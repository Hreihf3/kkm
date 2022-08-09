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
        guard data.count == AptosSignatureEd25519.SIZE else {
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
    public static let BITMAP_LEN: Int = 4
    
    public let signatures: [AptosSignatureEd25519]
    public let bitmap: Data
    
    public init(signatures: [AptosSignatureEd25519], bitmap: Data) throws {
        guard bitmap.count == Self.BITMAP_LEN else {
            throw AptosError.keyError("Bitmap length is \(Self.BITMAP_LEN) bytes.")
        }
        
        self.signatures = signatures
        self.bitmap = bitmap
    }
}

extension AptosMultiEd25519Signature: BorshCodable {
    public func serialize(to writer: inout Data) throws {
        var data = Data()
        for sig in signatures {
            data.append(sig.data)
        }
        data.append(bitmap)
        
        try VarData(data).serialize(to: &writer)
    }
    
    public init(from reader: inout BinaryReader) throws {
        let data = try VarData.init(from: &reader).data
        
        var sigs: [AptosSignatureEd25519] = []
        let count = (data.count - Self.BITMAP_LEN) / AptosSignatureEd25519.SIZE
        for i in 0..<count {
            let start = i * AptosSignatureEd25519.SIZE
            let end = (i + 1) * AptosSignatureEd25519.SIZE
            sigs.append(try AptosSignatureEd25519(data.subdata(in: start..<end)))
        }
        
        self.signatures = sigs
        self.bitmap = data.subdata(in: (data.count - Self.BITMAP_LEN)..<data.count)
    }
}

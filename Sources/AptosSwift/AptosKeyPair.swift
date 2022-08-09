//
//  AptosKeyPair.swift
//  
//
//  Created by xgblin on 2022/8/2.
//

import Foundation
import TweetNacl
import BIP39swift
import CryptoSwift

public struct AptosKeyPairEd25519 {
    public var mnemonics: String?
    public var secretKey: Data
    public var address: AptosAddress
    
    public var privateKeyData: Data {
        return secretKey[0..<32]
    }
    
    public var publicKeyData: Data {
        return secretKey[32..<64]
    }
    
    public var privateKey: String {
        return self.privateKeyData.toHexString().addHexPrefix()
    }
    
    public var publicKey: String {
        return self.publicKeyData.toHexString().addHexPrefix()
    }
    
    public init(privateKeyData: Data) throws {
        try self.init(seed: privateKeyData)
    }
    
    public init(seed: Data) throws {
        guard seed.count == 32 else {
            throw AptosError.keyError("Invalid Seed")
        }
        let keyPair = try NaclSign.KeyPair.keyPair(fromSeed: seed)
        self.secretKey = keyPair.secretKey
        self.address = try AptosAddress(Data(keyPair.publicKey.bytes + [0x00]).sha3(.sha256))
    }
    
    public init(mnemonics: String) throws {
        guard let seed = BIP39.seedFromMmemonics(mnemonics) else {
            throw AptosError.keyError("Invalid Mnemonics")
        }
        try self.init(seed: seed.subdata(in: 0..<32))
        self.mnemonics = mnemonics
    }
    
    public static func randomKeyPair() throws -> AptosKeyPairEd25519 {
        guard let mnemonic = try? BIP39.generateMnemonics(bitsOfEntropy: 128) else{
            throw AptosError.keyError("Invalid Mnemonics")
        }
        return try AptosKeyPairEd25519(mnemonics: mnemonic)
    }
}

// MARK: - Sign & Verify

extension AptosKeyPairEd25519 {
    public func sign(message: Data) throws -> AptosSignatureEd25519 {
         let signature = try NaclSign.signDetached(message: message, secretKey: secretKey)
        return try AptosSignatureEd25519(signature)
    }
    
    public func signVerify(message: Data, signature: Data) -> Bool {
        guard let ret = try? NaclSign.signDetachedVerify(message: message, sig: signature, publicKey: publicKeyData) else {
            return false
        }
        return ret
    }
}

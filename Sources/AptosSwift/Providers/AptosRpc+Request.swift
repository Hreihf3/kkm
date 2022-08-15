//
//  AptosRpc+Request.swift
//  
//
//  Created by Forrest on 2022/8/15.
//

import Foundation

public struct AptosPRCRequest {
    public enum AptosAccountSignature: Encodable {
        case Ed25519(AptosAcountAuthenticatorEd25519)
        case MultiEd25519(AptosAccountAuthenticatorMultiEd25519)
        case Unknown
        
        public var type: String {
            switch self {
            case .Ed25519(_):
                return "account_ed25519_signature"
            case .MultiEd25519(_):
                return "account_multi_ed25519_signature"
            case .Unknown:
                return ""
            }
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(self.type, forKey: .type)
        }
        
        public enum CodingKeys: String, CodingKey {
            case type = "type"
        }
    }
    
    public enum AptosTransactionSignature: Encodable {
        case Ed25519(AptosTransactionAuthenticatorEd25519)
        case MultiEd25519(AptosTransactionAuthenticatorMultiEd25519)
        case MultiAgent(AptosTransactionAuthenticatorMultiAgent)
        case Unknwon
        
        public var type: String {
            switch self {
            case .Ed25519(_):
                return "ed25519_signature"
            case .MultiEd25519(_):
                return "multi_ed25519_signature"
            case .MultiAgent(_):
                return "multi_agent_signature"
            case .Unknwon:
                return ""
            }
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(self.type, forKey: .type)
            
            switch self {
            case .Ed25519(let authenticator):
                try container.encode(authenticator.publicKey.hex, forKey: .publicKey)
                try container.encode(authenticator.signature.hex, forKey: .signature)
            case .MultiEd25519(let authenticator):
                try container.encode(authenticator.publicKey.publicKeys.map({$0.hex}), forKey: .publicKeys)
                try container.encode(authenticator.signature.signatures.map({$0.hex}), forKey: .signatures)
                try container.encode(authenticator.publicKey.threshold, forKey: .threshold)
                try container.encode(authenticator.signature.bitmap.toHexString().addHexPrefix(), forKey: .bitmap)
            case .MultiAgent(let authenticator):
//                try container.encode(authenticator.sender, forKey: .sender)
                try container.encode(authenticator.secondarySignerAddresses.map({$0.address}), forKey: .secondarySignerAddresses)
//                try container.encode(authenticator.secondarySigners, forKey: .secondarySigners)
            case .Unknwon:
                break
            }
        }
        
        public enum CodingKeys: String, CodingKey {
            case type = "type"
            case publicKey = "public_key"
            case signature = "signature"
            case publicKeys = "public_keys"
            case signatures = "signatures"
            case threshold = "threshold"
            case bitmap = "bitmap"
            case sender = "sender"
            case secondarySignerAddresses = "secondary_signer_addresses"
            case secondarySigners = "secondary_signers"
        }
    }
    
    public struct SubmitTransaction {
        public let sender: String
        public let sequence_number: String
        public let max_gas_amount: String
        public let gas_unit_price: String
        public let expiration_timestamp_secs: String
        public let payload: AptosTransactionPayload
        public let signature: AptosTransactionAuthenticator
    }
    
}

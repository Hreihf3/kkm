//
//  File.swift
//  
//
//  Created by xgblin on 2022/8/2.
//

import Foundation
//chaininfo
public struct ChainInfo: Codable {
    public let chainId: Int
    public let epoch: String
    public let ledgerVersion: String
    public let oldestLedgerVersion: String
    public let ledgerTimestamp: String
    public let nodeRole: String
}
//AccountResult
public struct AccountResult: Codable {
    public let sequenceNumber: String
    public let authenticationKey: String
}
//AccountResource
public struct AccountResource: Codable {
    public let type: String
    public let data: AccountResourceData
}

public struct AccountResourceData: Codable {
    public let coin: DataCoin?
    public let couter: String?
    public let depositEvents: DataEvents?
    public let withdrawEvents: DataEvents?
    
    public struct DataCoin: Codable {
        public let value: String
    }
    
    public struct DataEvents: Codable {
        public let counter: String
        public let guid: DataEventsGuid
        
        public struct DataEventsGuid: Codable {
            public let id: guidId
            public struct guidId: Codable {
                public let addr: String
                public let creationNum: String
            }
        }
    }
}

// transaction
public struct TransactionResult: Codable {
    public let type: String
    public let hash: String
    public let sender: String
    public let sequenceNumber: String
    public let maxGasAmount: String
    public let gasUnitPrice: String
    public let expirationTimestampSecs: String
    public let payload: PayloadResult
    public let signature: SignatureResult
}

public struct PayloadResult: Codable {
    public let type: String
    public let function: String
    public let typeArguments: [String]
    public let arguments: [String]
}

public struct SignatureResult: Codable {
    public let type: String
    public let publicKey: String
    public let signature: String
}

public struct RequestError: Codable {
    public let code: Int
    public let message: String
}

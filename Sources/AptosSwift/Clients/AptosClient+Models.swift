//
//  AptosClientModels.swift
//  
//
//  Created by Forrest on 2022/8/15.
//

import Foundation
import AnyCodable

extension AptosClient {
    public struct Error: Decodable {
        public let errorCode: String
        public let message: String
    }
    
    public struct Healthy: Decodable {
        public let message: String
    }
    
    public struct LedgerInfo: Decodable {
        public let epoch: String
        public let chainId: Int
        public let blockHeight: String
        public let ledgerVersion: String
        public let ledgerTimestamp: String
        public let nodeRole: String
    }
    
    public struct AccountData: Decodable {
        public let sequenceNumber: String
        public let authenticationKey: String
    }
    
    public struct AccountResourceData: Decodable {
        public struct Guid: Decodable {
            public let id: Id
            
            public struct Id: Decodable {
                public let addr: String
                public let creationNum: String
            }
        }
        
        public struct CoinStore: Decodable {
            public let coin: Coin
            public let depositEvents: DepositEvents
            public let withdrawEvents: WithdrawEvents
            
            public struct Coin: Decodable {
                public let value: String
            }
            
            public struct DepositEvents: Decodable {
                public let counter: String
                public let guid: Guid
            }
            
            public struct WithdrawEvents: Decodable {
                public let counter: String
                public let guid: Guid
            }
        }
        
        public struct Acccount: Decodable {
            public let authenticationKey: String
            public let coinRegisterEvents: CoinRegisterEvents
            
            public struct CoinRegisterEvents: Decodable {
                public let counter: String
                public let guid: Guid
                public let sequenceNumber: String
            }
        }
    }
    
    public struct AccountResource: Decodable {
        public let type: String
        public let data: AnyCodable
        
        public func to<T: Decodable>(_ type: T.Type) throws -> T {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(type, from: JSONEncoder().encode(data))
        }
    }
    
    public struct MoveFunctionGenericTypeParam: Decodable {
        public let constraints: [String]?
    }
    
    public struct MoveFunction: Decodable {
        public let name: String
        public let visibility: String
        public let isEntry: Bool
        public let genericTypeParams: [MoveFunctionGenericTypeParam]
        public let params: [String]
        public let `return`: [String]
        
        public var paramTypes: [String] {
            return params.filter({ !($0 == "&signer" || $0 == "signer") })
        }
    }
    
    public struct MoveStructGenericTypeParam: Decodable {
        public let constraints: [String]?
    }
    
    public struct MoveStructField: Decodable {
        public let name: String
        public let type: String
    }
    
    public struct MoveStruct: Decodable {
        public let name: String
        public let isNative: Bool
        public let abilities: [String]
        public let genericTypeParams: [MoveStructGenericTypeParam]
        public let fields: [MoveStructField]
    }
    
    public struct MoveModule: Decodable {
        public let address: String
        public let name: String
        public let friends: [AnyCodable]
        public let exposedFunctions: [MoveFunction]
        public let structs: [MoveStruct]
    }
    
    public struct MoveModuleBytecode: Decodable {
        public let bytecode: String
        public let abi: MoveModule?
    }
    
    public struct MoveScriptBytecode: Decodable {
        public let bytecode: String
        public let abi: MoveFunction?
    }
    
    public struct Block: Decodable {
        public let blockHeight: String
        public let blockHash: String
        public let blockTimestamp: String
        public let firstVersion: String
        public let lastVersion: String
        public let transactions: [Transaction]?
    }
    
    public struct Event: Decodable {
        public let key: String?
        public let sequenceNumber: String
        public let type: String
        public let data: AnyCodable
    }
    
    public struct PendingTransaction: Decodable {
        public let hash: String
        public let sender: String
        public let sequenceNumber: String
        public let gasUnitPrice: String
        public let expirationTimestampSecs: String
        public let payload: AnyCodable
        public let signature: AnyCodable?
    }
    
    public struct UserTransaction: Decodable {
        public let version: String
        public let hash: String
        public let stateChangeHash: String
        public let eventRootHash: String
        public let gasUsed: String
        public let success: Bool
        public let vmStatus: String
        public let accumulatorRootHash: String
        public let changes: [AnyCodable]
        public let sender: String
        public let sequenceNumber: String
        public let maxGasAmount: String
        public let gasUnitPrice: String
        public let expirationTimestampSecs: String
        public let payload: AnyCodable
        public let signature: AnyCodable?
        public let events: [Event]
        public let timestamp: String
    }
    
    public typealias Transaction = [String: AnyCodable]
}

//
//  File.swift
//  
//
//  Created by xgblin on 2022/8/2.
//

import Foundation
//chaininfo
public struct ChainInfo:Codable {
    public let chainId:Int
    public let epoch:String
    public let ledgerVersion:String
    public let oldestLedgerVersion:String
    public let ledgerTimestamp:String
    public let nodeRole:String
}
//AccountResult
public struct AccountResult:Codable {
    public let sequenceNumber:String
    public let authenticationKey:String
}
//AccountResource
public struct AccountResource:Codable {
    public let type:String
    public let data:AccountResourceData
}

public struct AccountResourceData:Codable {
    public let coin:DataCoin?
    public let couter:String?
    public let depositEvents:DataEvents?
    public let withdrawEvents:DataEvents?
    
    public struct DataCoin:Codable {
        public let value:String
    }
    
    public struct DataEvents:Codable {
        public let counter:String
        public let guid:DataEventsGuid
        
        public struct DataEventsGuid:Codable {
            public let id:guidId
            public struct guidId:Codable {
                public let addr:String
                public let creationNum:String
            }
        }
    }
}

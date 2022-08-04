//
//  File.swift
//  
//
//  Created by 薛跃杰 on 2022/8/2.
//

import Foundation
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

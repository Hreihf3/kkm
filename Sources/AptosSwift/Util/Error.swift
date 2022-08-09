//
//  NearError.swift
//  
//
//  Created by mathwallet on 2022/7/15.
//

import Foundation

public enum NearError: LocalizedError {
    case unknown
    case notExpected
    case decodingError
    case serializeError
    case providerError(String)
    case keyError(String)
    
    public var errorDescription: String? {
        switch self {
        case .unknown:
            return "Unknown error"
        case .notExpected:
            return "Not Expected"
        case .decodingError:
            return "Decoding error"
        case .serializeError:
            return "Serialize Error"
        case .providerError(let message):
            return message
        case .keyError(let message):
            return message
        }
    }
}

//
//  NearError.swift
//  
//
//  Created by mathwallet on 2022/7/15.
//

import Foundation

public enum AptosError: LocalizedError {
    case decodingError
    case serializeError
    case providerError(String)
    case keyError(String)
    case otherEror(String)
    
    public var errorDescription: String? {
        switch self {
        case .decodingError:
            return "Decoding error"
        case .serializeError:
            return "Serialize Error"
        case .providerError(let message):
            return message
        case .keyError(let message):
            return message
        case .otherEror(let message):
            return message
        }
    }
}

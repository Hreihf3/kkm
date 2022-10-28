//
//  NearError.swift
//  
//
//  Created by mathwallet on 2022/7/15.
//

import Foundation

public enum AptosError: LocalizedError {
    case deserializeError
    case serializeError
    case decodingError
    case encodingError
    case providerError(String)
    case keyError(String)
    case otherEror(String)
    case resoultError(String, String)
    
    public var errorDescription: String? {
        switch self {
        case .deserializeError:
            return "Deserialize Error"
        case .serializeError:
            return "Serialize Error"
        case .decodingError:
            return "Decoding error"
        case .encodingError:
            return "Encoding error"
        case .providerError(let message):
            return message
        case .keyError(let message):
            return message
        case .otherEror(let message):
            return message
        case .resoultError(_, let message):
            return message
        }
    }
}

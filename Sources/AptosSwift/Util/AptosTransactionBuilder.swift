//
//  AptosTransactionBuilder.swift
//  
//
//  Created by mathwallet on 2022/10/21.
//

import Foundation

public struct AptosTransactionBuilder {
    public init() {}
    
    public func ensureBool(arg: Any) throws -> Bool {
        if type(of: arg) == Bool.self {
            return arg as! Bool
        }
        if type(of: arg) == String.self {
            return (arg as! NSString).boolValue
        }
        throw AptosError.serializeError
    }
    
    public func ensureUInt8(arg: Any) throws -> UInt8 {
        if type(of: arg) == UInt8.self {
            return arg as! UInt8
        }
        if type(of: arg) == String.self, let v = UInt8(arg as! String) {
            return v
        }
        throw AptosError.serializeError
    }
    
    public func ensureUInt64(arg: Any) throws -> UInt64 {
        if type(of: arg) == UInt64.self {
            return arg as! UInt64
        }
        if type(of: arg) == Int.self {
            return arg as! UInt64
        }
        if type(of: arg) == String.self, let v = UInt64(arg as! String) {
            return v
        }
        throw AptosError.serializeError
    }
    
    public func ensureUInt128(arg: Any) throws -> UInt128 {
        if type(of: arg) == UInt128.self {
            return arg as! UInt128
        }
        if type(of: arg) == String.self, let v = UInt128(arg as! String) {
            return v
        }
        throw AptosError.serializeError
    }
    
    public func ensureAddress(arg: Any) throws -> AptosAddress {
        if type(of: arg) == AptosAddress.self {
            return arg as! AptosAddress
        }
        if type(of: arg) == String.self, let v = try? AptosAddress(arg as! String) {
            return v
        }
        throw AptosError.serializeError
    }
    
    public func ensureVector(arg: Any) throws -> Array<Any> {
        if let v = arg as? Array<Any> {
            return v
        }
        throw AptosError.serializeError
    }
    
    public func ensureString(arg: Any) throws -> String {
        if type(of: arg) == String.self {
            return arg as! String
        }
        throw AptosError.serializeError
    }
    
    public func serializeArg(_ arg: Any, type: AptosTypeTag, to writer: inout Data) throws {
        switch type {
        case .Bool:
            try ensureBool(arg: arg).serialize(to: &writer)
        case .UInt8:
            try ensureUInt8(arg: arg).serialize(to: &writer)
        case .UInt64:
            try ensureUInt64(arg: arg).serialize(to: &writer)
        case .UInt128:
            try ensureUInt128(arg: arg).serialize(to: &writer)
        case .Address:
            try ensureAddress(arg: arg).serialize(to: &writer)
        case .Vector(let typeTag):
            let v = try ensureVector(arg: arg)
            try UVarInt(v.count).serialize(to: &writer)
            try v.forEach({ try serializeArg($0, type: typeTag, to: &writer) })
        case .Struct(let structTag):
            if structTag.rawValue == "0x1::string::String" {
                try ensureString(arg: arg).serialize(to: &writer)
            } else {
                throw AptosError.serializeError
            }
        default:
            throw AptosError.serializeError
        }
    }
    
    public func serializeArgs(_ args: [Any], typeTags: [AptosTypeTag], to writer: inout Data) throws {
        guard args.count == typeTags.count else { throw AptosError.serializeError }
        
        var datas = [Data]()
        for (i, arg) in args.enumerated() {
            var d = Data()
            try serializeArg(arg, type: typeTags[i], to: &d)
            datas.append(d)
        }
        try datas.map({VarData($0)}).serialize(to: &writer)
    }
}

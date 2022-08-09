//
//  Transaction.swift
//  
//
//  Created by xgblin on 2022/8/9.
//

import Foundation

public struct Transaction {
    public var sender: AptosAddress
    public var sequence_number: UInt64
    public var payload: TransactionPayload
    public var max_gas_amount: UInt64
    public var gas_unit_price: UInt64
    public var expiration_timestamp_secs: UInt64
    public var chain_id: Int
}

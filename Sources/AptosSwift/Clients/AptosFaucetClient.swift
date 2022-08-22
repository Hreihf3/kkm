//
//  AptosFaucetClient.swift
//  
//
//  Created by mathwallet on 2022/8/22.
//

import Foundation
import PromiseKit

public class AptosFaucetClient: AptosClientBase {
    
    /// This creates an account if it does not exist and mints the specified amount of coins into that account
    /// - Parameters:
    ///   - address:  Aptos account address
    ///   - amount: Amount of tokens to mint
    /// - Returns: Hashes of submitted transactions
    public func fundAccount(address: AptosAddress, amount: UInt64) -> Promise<[String]> {
        let queryParameters: [String: Any] = [
            "address": address.address,
            "amount": amount
        ]
        return POST(path: "/mint", queryParameters: queryParameters)
    }
}

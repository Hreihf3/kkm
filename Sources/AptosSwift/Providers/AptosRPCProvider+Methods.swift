//
//  AptosRPCProvider+Methods.swift
//  
//
//  Created by mathwallet on 2022/8/15.
//

import Foundation
import PromiseKit

extension AptosRPCProvider {
    public func getChainInfo() -> Promise<AptosRPC.ChainInfo> {
        return GET(path: "/v1")
    }
    
    public func getAccountData(address: AptosAddress) -> Promise<AptosRPC.AccountData> {
        return GET(path: "/v1/accounts/\(address.address)")
    }
    
    public func getAccountResources(address: AptosAddress) -> Promise<[AptosRPC.AccountResource]> {
        return GET(path: "/v1/accounts/\(address.address)/resources")
    }
    
    public func getAccountResource(address: AptosAddress, resourceType: String) -> Promise<AptosRPC.AccountResource> {
        return GET(path: "/v1/accounts/\(address.address)/resource/\(resourceType)")
    }
    
    /// Submits a signed transaction to the the endpoint that takes BCS payload
    /// - Parameter signedTransaction: A BCS signed transaction
    /// - Returns: Transaction that is accepted and submitted to mempool
    public func submitSignedTransaction(_ signedTransaction: AptosSignedTransaction) -> Promise<AptosRPC.PendingTransaction> {
        let headers: [String: String] = ["Content-Type": "application/x.aptos.signed_transaction+bcs"]
        return POST(path: "/v1/transactions", body: try? BorshEncoder().encode(signedTransaction), headers: headers)
    }
    
    /// Submits a transaction to the the endpoint that takes BCS payload
    /// - Parameter rawTransaction AptosRawTransaction
    /// - Parameter publicKey AptosPublicKeyEd25519
    /// - Returns: Simulation result in the form of UserTransaction
    public func simulateTransaction(_ rawTransaction: AptosRawTransaction, publicKey: AptosPublicKeyEd25519) -> Promise<[AptosRPC.UserTransaction]> {
        let signedTransaction = rawTransaction.simulate(publicKey)
        let headers: [String: String] = ["Content-Type": "application/x.aptos.signed_transaction+bcs"]
        return POST(path: "/v1/transactions/simulate", body: try? BorshEncoder().encode(signedTransaction), headers: headers)
    }
}

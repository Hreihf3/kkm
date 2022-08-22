//
//  AptosClientProvider+Methods.swift
//  
//
//  Created by mathwallet on 2022/8/15.
//

import Foundation
import PromiseKit

public class AptosClient: AptosClientBase {
    
    /// Check basic node health
    /// - Parameter durationSecs: If the duration_secs param is provided, this endpoint will return a 200 if the following condition is true:
    ///     server_latest_ledger_info_timestamp >= server_current_time_timestamp - duration_secs
    /// - Returns: AptosClient.Healthy
    public func healthy(durationSecs: UInt32? = nil) -> Promise<AptosClient.Healthy> {
        var parameters: [String : Any]?
        if let secs = durationSecs {
            parameters = ["duration_secs": secs]
        }
        return GET(path: "/v1/-/healthy", parameters: parameters)
    }
    
    /// Get the latest ledger information, including data such as chain ID, role type, ledger versions, epoch, etc.
    /// - Returns: AptosClient.LedgerInfo
    public func getLedgerInfo() -> Promise<AptosClient.LedgerInfo> {
        return GET(path: "/v1")
    }
    
    /// Get blocks by height
    /// - Parameters:
    ///   - blockHeight: Block Height
    ///   - withTransactions: true,false,nil
    /// - Returns: AptosClient.Block
    public func getBlock(_ blockHeight: UInt64, withTransactions: Bool? = nil) -> Promise<AptosClient.Block> {
        var parameters: [String : Any]?
        if let wt = withTransactions {
            parameters = ["with_transactions": wt]
        }
        return GET(path: "/v1/blocks/by_height/\(blockHeight)", parameters: parameters)
    }
    
    /// Get account
    /// - Parameter address: Hex encoded 32 byte Aptos account address
    /// - Returns: high level information about an account such as its sequence number
    public func getAccount(address: AptosAddress) -> Promise<AptosClient.AccountData> {
        return GET(path: "/v1/accounts/\(address.address)")
    }
    
    /// Get account resources
    /// - Parameter address: Hex encoded 32 byte Aptos account address
    /// - Returns: all account resources
    public func getAccountResources(address: AptosAddress) -> Promise<[AptosClient.AccountResource]> {
        return GET(path: "/v1/accounts/\(address.address)/resources")
    }
    
    /// Get specific account resource
    /// - Parameters:
    ///   - address: Hex encoded 32 byte Aptos account address
    ///   - resourceType: String representation of a MoveStructTag (on-chain Move struct type).
    ///                   This exists so you can specify MoveStructTags as path / query parameters, e.g. for get_events_by_event_handle.
    /// - Returns: the resource of a specific type
    public func getAccountResource(address: AptosAddress, resourceType: String) -> Promise<AptosClient.AccountResource> {
        return GET(path: "/v1/accounts/\(address.address)/resource/\(resourceType)")
    }
    
    /// Get account modules
    /// - Parameter address: Hex encoded 32 byte Aptos account address
    /// - Returns: All account modules at a given address at a specific ledger version (AKA transaction version)
    public func getAccountModules(address: AptosAddress) -> Promise<[AptosClient.AccountModule]> {
        return GET(path: "/v1/accounts/\(address.address)/modules")
    }
    
    /// Get specific account module
    /// - Parameters:
    ///   - address: Hex encoded 32 byte Aptos account address
    ///   - moduleName: Module name
    /// - Returns: the module with a specific name residing at a given account at a specified ledger version (AKA transaction version)
    public func getAccountModule(address: AptosAddress, moduleName: String) -> Promise<AptosClient.AccountModule> {
        return GET(path: "/v1/accounts/\(address.address)/module/\(moduleName)")
    }
    
    /// Submits a signed transaction to the the endpoint that takes BCS payload
    /// - Parameter signedTransaction: A BCS signed transaction
    /// - Returns: Transaction that is accepted and submitted to mempool
    public func submitSignedTransaction(_ signedTransaction: AptosSignedTransaction) -> Promise<AptosClient.PendingTransaction> {
        let headers: [String: String] = ["Content-Type": "application/x.aptos.signed_transaction+bcs"]
        return POST(path: "/v1/transactions", body: try? BorshEncoder().encode(signedTransaction), headers: headers)
    }
    
    /// Submits a transaction to the the endpoint that takes BCS payload
    /// - Parameter rawTransaction AptosRawTransaction
    /// - Parameter publicKey AptosPublicKeyEd25519
    /// - Returns: Simulation result in the form of UserTransaction
    public func simulateTransaction(_ rawTransaction: AptosRawTransaction, publicKey: AptosPublicKeyEd25519) -> Promise<[AptosClient.UserTransaction]> {
        let signedTransaction = rawTransaction.simulate(publicKey)
        let headers: [String: String] = ["Content-Type": "application/x.aptos.signed_transaction+bcs"]
        return POST(path: "/v1/transactions/simulate", body: try? BorshEncoder().encode(signedTransaction), headers: headers)
    }
    
    /// Get transaction by hash
    /// - Parameter txnHash: Transaction Hash
    /// - Returns: AptosClient.Block
    public func getTransactionByHash(_ txnHash: String) -> Promise<AptosClient.Transaction> {
        return GET(path: "/v1/transactions/by_hash/\(txnHash)")
    }
}

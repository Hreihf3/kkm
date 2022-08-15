//
//  AptosRPCProvider.swift
//  
//
//  Created by xgblin on 2022/8/2.
//

import Foundation
import PromiseKit

public struct AptosRPCProvider {
    public var nodeUrl: URL
    private var session: URLSession
    
    public init(nodeUrl: URL) {
        self.nodeUrl = nodeUrl
        
        self.session = URLSession(configuration: .default)
    }
    
    public func getChainInfo() -> Promise<ChainInfo> {
        return self.GET()
    }
    
    public func getAccount(address: AptosAddress) -> Promise<AccountResult> {
        return self.GET(path: "/accounts/\(address.address)")
    }
    
    public func getAccountResources(address: AptosAddress) -> Promise<[AccountResource]> {
        return self.GET(path: "/accounts/\(address.address)/resources")
    }
    
    public func getAccountResource(address: AptosAddress, resourceType: String) -> Promise<AccountResource> {
        return self.GET(path: "/accounts/\(address.address)/resource/\(resourceType)")
    }
    
    /// Submits a signed transaction to the the endpoint that takes BCS payload
    /// - Parameter signedTransaction: A BCS signed transaction
    /// - Returns: Transaction that is accepted and submitted to mempool
    public func submitSignedTransaction(_ signedTransaction: AptosSignedTransaction) -> Promise<TransactionResult> {
        let headers: [String: String] = ["Content-Type": "application/x.aptos.signed_transaction+bcs"]
        return self.POST(path: "/transactions", body: try? BorshEncoder().encode(signedTransaction), headers: headers)
    }
    
    /// Submits a signed transaction to the the endpoint that takes BCS payload
    /// - Parameter signedTxn output of generateBCSSimulation()
    /// - Returns: Simulation result in the form of UserTransaction
    public func simulateSignedTransaction(_ signedTransaction: AptosSignedTransaction) -> Promise<TransactionResult> {
        let headers: [String: String] = ["Content-Type": "application/x.aptos.signed_transaction+bcs"]
        return self.POST(path: "/transactions/simulate", body: try? BorshEncoder().encode(signedTransaction), headers: headers)
    }
}

extension AptosRPCProvider {
    
    public func GET<T: Codable>(path: String? = nil) -> Promise<T> {
        debugPrint("GET")
        let rp = Promise<Data>.pending()
        var task: URLSessionTask? = nil
        let queue = DispatchQueue(label: "aptos.get")
        queue.async {
            let url = URL(string: "\(self.nodeUrl.absoluteString)\(path ?? "")")!
            debugPrint(url)
            var urlRequest = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.reloadIgnoringCacheData)
            urlRequest.httpMethod = "GET"
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")

            task = self.session.dataTask(with: urlRequest){ (data, response, error) in
               guard error == nil else {
                   rp.resolver.reject(error!)
                   return
               }
               guard data != nil else {
                   rp.resolver.reject(AptosError.providerError("Node response is empty"))
                   return
               }
               rp.resolver.fulfill(data!)
            }
            task?.resume()
        }
        return rp.promise.ensure(on: queue) {
            task = nil
        }.map(on: queue){ (data: Data) throws -> T in
            debugPrint(String(data: data, encoding: .utf8) ?? "")
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            if let resp = try? decoder.decode(T.self, from: data) {
               return resp
            }
            if let errorResult = try? decoder.decode(RequestError.self, from: data) {
               throw AptosError.providerError(errorResult.message)
            }
            throw AptosError.providerError("Parameter error or received wrong message")
        }
    }
    
    public func POST<T: Decodable, K: Encodable>(path: String? = nil, parameters: K? = nil) -> Promise<T> {
        let body: Data? = (parameters != nil ? try? JSONEncoder().encode(parameters!) : nil)
        return POST(path: path, body: body, headers: [:])
    }
    
    public func POST<T: Decodable>(path: String? = nil, body: Data? = nil, headers: [String: String] = [:]) -> Promise<T> {
        debugPrint("POST")
        let rp = Promise<Data>.pending()
        var task: URLSessionTask? = nil
        let queue = DispatchQueue(label: "aptos.post")
        queue.async {
            let url = URL(string: "\(self.nodeUrl.absoluteString)\(path ?? "")")!
            debugPrint(url)
            var urlRequest = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.reloadIgnoringCacheData)
            urlRequest.httpMethod = "POST"
            
            for key in headers.keys {
                urlRequest.setValue(headers[key], forHTTPHeaderField: key)
            }
            if !headers.keys.contains("Content-Type") {
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
            if !headers.keys.contains("Accept") {
                urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
            }
            urlRequest.httpBody = body
            debugPrint(body?.toHexString() ?? "")

            task = self.session.dataTask(with: urlRequest){ (data, response, error) in
                guard error == nil else {
                    rp.resolver.reject(error!)
                    return
                }
                guard data != nil else {
                    rp.resolver.reject(AptosError.providerError("Node response is empty"))
                    return
                }
                rp.resolver.fulfill(data!)
            }
            task?.resume()
        }
        return rp.promise.ensure(on: queue) {
            task = nil
        }.map(on: queue){ (data: Data) throws -> T in
            debugPrint(String(data: data, encoding: .utf8) ?? "")
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            if let resp = try? decoder.decode(T.self, from: data) {
                return resp
            }
            if let errorResult = try? decoder.decode(RequestError.self, from: data) {
                throw AptosError.providerError(errorResult.message)
            }
            throw AptosError.providerError("Parameter error or received wrong message")
        }
    }
}

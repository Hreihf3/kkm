//
//  AptosRPCProvider.swift
//  
//
//  Created by 薛跃杰 on 2022/8/2.
//

import Foundation
import Alamofire
import PromiseKit

public struct AptosRPCProvider {
    public var nodeUrl:String
    
    public init(nodeUrl: String) {
        self.nodeUrl = nodeUrl
    }
    
    public func getAccount(address:String) -> Promise<AccountResult> {
        return self.GET(url: "\(nodeUrl)/accounts/\(address)")
    }
}

extension AptosRPCProvider {
    func GET<T:Codable>(url:String) -> Promise<T> {
        let (promise,seal) = Promise<T>.pending()
        AF.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).responseData { response in
            switch response.result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let result = try decoder.decode(T.self, from: data)
                    seal.fulfill(result)
                } catch let e{
                    seal.reject(e)
                }
            case let .failure(e):
                seal.reject(e)
            }
        }
        return promise
    }
    
    func POST<T:Codable>(url:String,parameters:Parameters) -> Promise<T> {
        let (promise,seal) = Promise<T>.pending()
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseData { response in
            switch response.result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let result = try decoder.decode(T.self, from: data)
                    seal.fulfill(result)
                } catch let e{
                    seal.reject(e)
                }
            case let .failure(e):
                seal.reject(e)
            }
        }
        return promise
    }
}

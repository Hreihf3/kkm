//
//  URL+Extension.swift
//  
//
//  Created by mathwallet on 2022/6/30.
//

import Foundation

extension URL {
    func appendingQueryParameters(_ parameters: [String: Any]? = nil) -> URL {
        guard let p = parameters, !p.isEmpty else {
            return self
        }
        var urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: true)!
        var items = urlComponents.queryItems ?? []
        items += p.map({ URLQueryItem(name: $0, value: "\($1)") })
        urlComponents.queryItems = items
        return urlComponents.url!
    }
    
    func appendPath(_ path: String) -> URL {
        return self.appendingPathComponent(path)
    }
}

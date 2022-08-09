//
//  String+Extension.swift
//  
//
//  Created by xgblin on 2022/8/3.
//

import Foundation

extension String {
    func addHexPrefix() -> String {
        if !self.hasPrefix("0x") {
            return "0x" + self
        }
        return self
    }
}

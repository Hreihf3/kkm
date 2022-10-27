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
    
    func stripHexPrefix() -> String {
        if self.hasPrefix("0x") {
            let indexStart = self.index(self.startIndex, offsetBy: 2)
            return String(self[indexStart...])
        }
        return self
    }
    
    func isHex() -> Bool {
        let regex = try? NSRegularExpression(pattern: "^[A-Fa-f0-9]+$", options: .caseInsensitive)
        let text = self.stripHexPrefix()
        if let result = regex?.matches(in: text, options: [], range: NSRange(location: 0, length: text.count)), result.count > 0 {
            return true
        }
        return false
    }
}

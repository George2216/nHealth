//
//  PhoneExtensions.swift
//  AppointmentProject
//
//  Created by George on 30.10.2021.
//

import Foundation

extension String {
    enum PhoneSymbolCount {
    case ten
    }
    enum RegularExpressions: String {
        case phone = "^\\s*(?:\\+?(\\d{1,3}))?([-. (]*(\\d{3})[-. )]*)?((\\d{3})[-. ]*(\\d{2,4})(?:[-.x ]*(\\d+))?)\\s*$"
    }
    
   func isValid(regex: RegularExpressions) -> Bool {
       return isValid(regex: regex.rawValue) && self.count >= 10
   }
    
   private func isValid(regex: String) -> Bool {
        let matches = range(of: regex, options: .regularExpression)
        return matches != nil
    }
    
   private func onlyDigits() -> String {
        let filtredUnicodeScalars = unicodeScalars.filter{CharacterSet.decimalDigits.contains($0)}
        return String(String.UnicodeScalarView(filtredUnicodeScalars))
    }
    
    func removeFirst(_ count:PhoneSymbolCount) -> String {
        switch count {
        case .ten:
            guard self.count >= 10 else { return "" }
            let removeCount = self.count - 10
            var selfStr = self
            selfStr.removeFirst(removeCount)
            return selfStr
        }
    }
}

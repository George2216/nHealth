//
//  ArrayOperationsExtensions.swift
//  AppointmentProject
//
//  Created by George on 30.10.2021.
//

import Foundation
extension Array {
    func isHaveEqual<T:Equatable>(array:[T]) -> Bool {
        guard let self = self as? Array<T>  else { return false }
        for item in array {
            if  self.contains(item) {
                return true
            }
        }
        return false
    }
}


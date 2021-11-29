//
//  StringOperationsExstensions.swift
//  AppointmentProject
//
//  Created by George on 30.10.2021.
//

import Foundation

extension String {
    func changeSymbol(_ symbol:Character,on:String) -> String {
        var outputStr = ""
        for char in self {
            if char == symbol {
                outputStr.append(on)
            } else {
                outputStr.append(char)
            }
        }
        return outputStr
    }
    
    func cutString(to count:Int) -> String {
        var finishString = ""
        for (index,value) in self.enumerated() {
            finishString.append(value)
            if index  == count - 1 {
                return finishString
            }
        }
        return ""
    }
    
    func cutString(from:Int,to:Int) -> String {
        var finishString = ""
        for (index , value) in self.enumerated() {
            if index >= from && index <= to {
                finishString.append(value)
            }
        }
       return finishString
    }
    
    func cutString(to:Character) -> String? {
        var finishString = ""
        for value in self {
            if value == to {
                return finishString
            }
            finishString.append(value)
        }
        
        return nil
    }
    
    func cutString(from:Character) -> String {
        var flag = false
        var finishString = ""
        for value in self {
            if flag {
                finishString.append(value)
            }
            if value == from {
                flag = true
            }
            
        }
        
        return finishString
    }
    func removeLast(count:Int) -> String {

        var newStr = ""
        for (index,value) in self.enumerated() {
            if (self.count - count) >= index + 1 {
                newStr.append(value)
            }
        }
        return newStr
    }
}

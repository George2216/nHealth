//
//  ExtensionsForDates.swift
//  AppointmentProject
//
//  Created by George on 30.10.2021.
//

import Foundation


extension Date {
    
    func adding(minutes: Int) -> Date {
        return Calendar.current.date(byAdding: .minute, value: minutes, to: self)!
    }
    
    func getDateComponents(component:Calendar.Component) -> Int? {
        switch component {
        case .day :
            return Calendar.current.dateComponents([.day], from: self).day
        case .year :
            return Calendar.current.dateComponents([.year], from: self).year
        case .month :
            return Calendar.current.dateComponents([.month], from: self).month
        case .weekday :
            return Calendar.current.dateComponents([.weekday], from: self).weekday
        default :
            return nil
        }
    }
    
    func monthAsString(_ locale:String) -> String {
        let df = DateFormatter()
        df.locale = Locale.init(identifier: locale)
        df.setLocalizedDateFormatFromTemplate("MMMM")
        return df.string(from: self)
    }
    
    func stringDF() -> String {
        let df = DateFormatter()
        df.dateFormat = "dd.MM.yyyy"
        df.locale = Locale.init(identifier: "ru_RU")
        return df.string(from: self)
    }
        
    func stringDateSpase() -> String {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        df.locale = Locale.init(identifier: "ru_RU")
        return df.string(from: self)
    }
    
    func stringDate(by:String) -> String {
        let df = DateFormatter()
        df.dateFormat = by
        df.locale = Locale.init(identifier: "ru_RU")
        return df.string(from: self)
    }
    
}

extension String {
    enum DateAtributed:String {
        case yyyy
        case MM
        case dd
    }
    func getDateAtributed(_ atribut:DateAtributed) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: self) else {
                return ""
            }

        switch atribut {
        case .yyyy :
            formatter.dateFormat = "yyyy"
            let year = formatter.string(from: date)
            return year
        case .MM :
            formatter.dateFormat = "MM"
            let month = formatter.string(from: date)
            return month
        case .dd :
            formatter.dateFormat = "dd"
            let day = formatter.string(from: date)
            return day
        }
    }
    
    func dateSpase() -> Date? {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
         return df.date(from: self)
    }
    
    func fullDateSpase() -> Date? {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        df.locale = Locale.init(identifier: "ru_RU")
        
        return df.date(from: self)
    }
    
    
}

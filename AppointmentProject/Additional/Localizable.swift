//
//  Localizable.swift
//  AppointmentProject
//
//  Created by George on 31.07.2021.
//

import Foundation
import RxSwift
import RxCocoa
import Foundation

class Localizable {
    
    static func localize(_ text:LocalizeString) -> Observable<String> {
         return SingletonData.shared.languageIndex.map({SingletonData.shared.systemArrayLanguage[$0]}).map({ language -> String in
             let path = Bundle.main.path(forResource: language, ofType: "lproj")
             let bundle = Bundle(path: path!)
                 
            return  NSLocalizedString(text.rawValue, tableName: nil, bundle: bundle!, value: "", comment: "")
         })
     }
    static func languageKey() -> Observable<String> {
        SingletonData.shared.languageIndex.map({SingletonData.shared.systemArrayLanguage[$0]})
    }
}
enum LocalizeString: String {
    case doctorName
    case filters
    case clear
    case language
    case appointments
    case doctors
    case doctor
    case close
    case subdivision
    case professions
    case signUp
    case fullName
    case save
    case invalidNamePhone
    case map
    case history
    case delete
    case goToDoctor
}

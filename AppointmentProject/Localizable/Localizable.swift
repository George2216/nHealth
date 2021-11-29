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
enum LocalizeString: String , Codable {
    // sities
    case kyiv
    case poltava
    case kharkiv
    case odessa
    
    case doctorName
    case doctors
    case doctor
    
    case filters
    case clear
    case appointments
   
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
    case settings
    case language
    case server
    case aboutUs
    case addServer
    case urlSelected
    case urlRequired
    case deleteUrlQu
    case locale
    case of
   
    case selectCity
    case selectClinic
    case selectYourCity
    case selectYourClinic
    case clinic
    case cityHeader
    case clinicHeader
    case clinicFooter
    case pushNotifications
    case receiveNf
    case soundNf
    case vibrationNf
    case appointmentNf
    case cancellationAppNf
    case goToSettings
    case goToSettingFooter
    case notificationSoundFooter
    case allNotificationFooter
    case soudsSettingsHeader
    case receiveNotificationHeader
    case youSignedUpFor
    case youCanceledOurAppointmentFor
    case discount
}


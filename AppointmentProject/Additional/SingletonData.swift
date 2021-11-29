//
//  SingletonData.swift
//  AppointmentProject
//
//  Created by George on 27.07.2021.
//

import Foundation
import RxSwift
import RxCocoa

final class SingletonData {
    private let disposeBag = DisposeBag()
    static  let shared = SingletonData()
    let arrayLanguage = ["Українська","English","Русский"]
    let systemArrayLanguage = ["uk","en","ru"]
    var token:String {
        if let token = UserDefaults.standard.value(forKey: UDKeys.requestToken.rawValue) as? String {
        return token
    }
    return ""
    }
    
    var defaultUrlPath:String {
        if let defaultUrlPath = UserDefaults.standard.value(forKey: UDKeys.urlPath.rawValue) as? String {
        return defaultUrlPath
    }
    return ""
    }
    
    let webViewPath = "http://vikisoft.kiev.ua/nhealth/"
    private static var defaultLanguage:Int {
        if  let indexLanguage = UserDefaults.standard.value(forKey: UDKeys.languageIndex.rawValue) as? Int {
            return indexLanguage
        }
        return 0
    }
    var languageIndex = BehaviorRelay<Int>(value: defaultLanguage)
    
    func getCentersListData() -> CentersListModel? {
         CentersListModel.getData(for: .Subdivisions)
}
    
    
private init() {
    languageIndex.subscribe(onNext: { index in
        UserDefaults.standard.set(index, forKey: UDKeys.languageIndex.rawValue)
        }).disposed(by: disposeBag)
}
   
   
}

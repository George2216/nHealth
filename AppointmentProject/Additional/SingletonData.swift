//
//  SingletonData.swift
//  AppointmentProject
//
//  Created by George on 27.07.2021.
//

import Foundation
import RxSwift
import RxCocoa

class SingletonData {
    
    private let disposeBag = DisposeBag()
    static let shared = SingletonData()
    let arrayLanguage = ["Українська","English","Русский"]
    let systemArrayLanguage = ["uk","en","ru"]
    
    private static var defaultLanguage:Int {
        if  let indexLanguage = UserDefaults.standard.value(forKey: UDKeys.languageIndex.rawValue) as? Int {
            return indexLanguage
        }
        return 0
    }
    var languageIndex = BehaviorRelay<Int>(value: defaultLanguage)
    
    func getCentersListData() -> CentersListModel? {
        if let subdivisionsData = UserDefaults().data(forKey: UDKeys.Subdivisions.rawValue) {
            guard let subdivision:CentersListModel = getPacketFromData(data: subdivisionsData) else {
                return nil
            }
            return subdivision
    }
        return nil
}
    
    
private init() {
    languageIndex.subscribe(onNext: { index in        UserDefaults.standard.set(index, forKey: UDKeys.languageIndex.rawValue)
        }).disposed(by: disposeBag)
    }
}

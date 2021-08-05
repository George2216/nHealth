//
//  CalendarControllerViewModel.swift
//  AppointmentProject
//
//  Created by George on 15.07.2021.
//

import Foundation
import RxSwift
import RxCocoa

extension CalendarControllerViewModel {
    var calengarLocale:Driver<String> {
        return Localizable.languageKey().asDriver(onErrorJustReturn: "")
    }
    var saveButtonLocalizable:Driver<String> {
        return Localizable.localize(.save).asDriver(onErrorJustReturn: "")
    }
    var cancelButtonLocalizable:Driver<String> {
        return Localizable.localize(.close).asDriver(onErrorJustReturn: "")
    }
}
class CalendarControllerViewModel: ViewModelProtocol {
    
   
    
    func transform(_ input: Input) -> Output {
        Output(calengarLocale: calengarLocale,saveButtonLocalizable:saveButtonLocalizable,cancelButtonLocalizable:cancelButtonLocalizable)
    }
    struct Input {
    }
    struct Output {
        let calengarLocale:Driver<String>
        let saveButtonLocalizable:Driver<String>
        let cancelButtonLocalizable:Driver<String>

    }
}

//
//  SettingsTableViewModel.swift
//  AppointmentProject
//
//  Created by George on 31.07.2021.
//

import Foundation
import RxCocoa
import RxSwift
extension SettingsTableViewModel {
    private var titleSettings:Driver<String> {
        return Localizable.localize(.settings).asDriverOnErrorJustComplete()
    }
    
    private var tableDataDriver:Driver<[ModelSettingCell]> {
        return tableData.asDriverOnErrorJustComplete()
    }
    private var pushLanguageDriver:Driver<Void> {
        return pushLanguage.asDriverOnErrorJustComplete()
    }
    private var pushServerDriver:Driver<Void> {
        return pushServer.asDriverOnErrorJustComplete()
    }
    private var pushAboutUsDriver:Driver<Void> {
        return pushAboutUs.asDriverOnErrorJustComplete()
    }
    private var pushPushNotificationDriver:Driver<Void> {
        return pushPushNotification.asDriverOnErrorJustComplete()
    }
}
final class SettingsTableViewModel: ViewModelProtocol {
    private let disposeBag = DisposeBag()
    private let tableData = BehaviorSubject<[ModelSettingCell]>(value: [])
    private let pushLanguage = PublishSubject<Void>()
    private let pushServer = PublishSubject<Void>()
    private let pushAboutUs = PublishSubject<Void>()
    private let pushPushNotification = PublishSubject<Void>()

    
    func transform(_ input: Input) -> Output {
        getTableData()
        selectCell(input)
        return Output(tableData: tableDataDriver, titleSettings: titleSettings,pushLanguage:pushLanguageDriver,pushServer:pushServerDriver,pushAboutUs:pushAboutUsDriver, pushPushNotification: pushPushNotificationDriver)
    }
    
    func getTableData() {
        Observable.combineLatest(Localizable.localize(.language), Localizable.localize(.clinic), Localizable.localize(.aboutUs),Localizable.localize(.pushNotifications)).subscribe(onNext:{ [self] languageTitle , serverTitle,aboutUsTitle , pushNotificationTitile in
            
           
            tableData.onNext([ModelSettingCell(textLabel: languageTitle, systeimageName: "globe"),ModelSettingCell(textLabel: serverTitle, systeimageName: "building.columns"),ModelSettingCell(textLabel: aboutUsTitle, systeimageName: "info"),ModelSettingCell(textLabel: pushNotificationTitile, systeimageName: "message.fill")])
        }).disposed(by: disposeBag)
        
    }
    func selectCell(_ input: Input) {
        input.selectCell.subscribe(onNext: { [self] selectIndex in
            switch selectIndex {
            case 0: pushLanguage.onNext(())
            case 1: pushServer.onNext(())
            case 2: pushAboutUs.onNext(())
            case 3: pushPushNotification.onNext(())
            default:break
            }
        }).disposed(by: disposeBag)
    }
    struct Input {
        let selectCell:Observable<Int>
    }
    
    struct Output {
        let tableData:Driver<[ModelSettingCell]>
        let titleSettings:Driver<String>
        let pushLanguage:Driver<Void>
        let pushServer:Driver<Void>
        let pushAboutUs:Driver<Void>
        let pushPushNotification:Driver<Void>
    }
}



struct ModelSettingCell {
    let textLabel:String
    let systeimageName:String
}

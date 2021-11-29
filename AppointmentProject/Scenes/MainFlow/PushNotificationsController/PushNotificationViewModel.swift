//
//  PushNotificationViewModel.swift
//  AppointmentProject
//
//  Created by George on 19.10.2021.
//

import RxSwift
import RxCocoa
import Foundation
import RxDataSources

struct NotificationCellModel:Codable{
    let title:String
    var isSelect:Bool
}

enum NotificationSectionType {
    case main(header:String?,footer:String?)
    case other(header:String?,footer:String?)
    
    var headerFooter:(header:String?,footer:String?) {
        switch self {
        case .main(let header,let footer):
            return (header,footer)
        case .other(let header,let footer):
            return (header,footer)
        }
    }
    
}
enum NotificationItem {
    case goToSettingsModel(title:String, imageName:String)
    case switchModelData(info:NotificationCellModel)
}

typealias NotificationSection = SectionModel<NotificationSectionType,NotificationItem>

extension PushNotificationVM {
    private var itemsDriver:Driver<[NotificationSection]> {
        items.asDriverOnErrorJustComplete()
    }
    private var title:Driver<String> {
        Localizable.localize(.pushNotifications).asDriverOnErrorJustComplete()
    }
}


final class PushNotificationVM: ViewModelProtocol {
    private let disposeBag = DisposeBag()
    private let items = BehaviorSubject<[NotificationSection]>(value: [])
    
    func transform(_ input: Input) -> Output {
        self.subscribeOnSelectCell(input)
        self.changeSwichValueForIndex(input)
        return Output(items: itemsDriver, title: title)
    }
    
    private func subscribeOnSelectCell(_ input: Input) {
        input.selectCell
            .subscribe(onNext:{ indexPath in
            switch indexPath {
            case IndexPath(row: 0, section: 0):
                AppDelegate.gotoAppSettings()
            default:
                break
            }
        }).disposed(by: disposeBag)
    }
    
    private func changeSwichValueForIndex(_ input: Input) {

        input.changeValueIndex
            .withLatestFrom(Observable.combineLatest(input.changeValueIndex,items)).subscribe(onNext: {[weak self] switchConfig  , itemsValue in
            guard let self = self else { return }
                
            var newItems = itemsValue
            let  selectedSwitch = itemsValue[switchConfig.indexPath.section].items[switchConfig.indexPath.row]
           
            
            switch selectedSwitch {
            case .switchModelData(info: let selected) :
                
                newItems[switchConfig.indexPath.section].items[switchConfig.indexPath.row] = .switchModelData(info: NotificationCellModel(title: selected.title, isSelect: switchConfig.isOn))
                
                if var notificationSettings = NotificationSettingsModel.getData(for: .notificationSettings) {
                    switch switchConfig.indexPath {
                    case IndexPath(row: 0, section: 1):
                        notificationSettings.sound = switchConfig.isOn
                    case IndexPath(row: 0, section: 2):
                        notificationSettings.completion = switchConfig.isOn
                    case IndexPath(row: 1, section: 2):
                        notificationSettings.cancellation = switchConfig.isOn
                    default:
                        break
                    }
                    
                    notificationSettings.saveSelfData(for: .notificationSettings)
                }
                self.items.onNext(newItems)
                default:
                    break
            }
            
        }).disposed(by: disposeBag)
       
    }
    
    private func getTableData()  {
      
        
        // max combine item - 8
        let firstLocalizableText =  Observable.combineLatest(
                Localizable.localize(.goToSettings),
                Localizable.localize(.soundNf),
                Localizable.localize(.goToSettingFooter),
                Localizable.localize(.appointmentNf),
                Localizable.localize(.cancellationAppNf),
                Localizable.localize(.notificationSoundFooter),
                Localizable.localize(.allNotificationFooter))
        
        let secondLocalizableText = Observable.combineLatest(Localizable.localize(.receiveNotificationHeader), Localizable.localize(.soudsSettingsHeader))
        
        Observable
            .combineLatest(firstLocalizableText, secondLocalizableText)
                    .subscribe(onNext: {  [weak self] firstСombination, secondСombination in
                        guard let self = self else { return }
                        
            if let notificationSettings = NotificationSettingsModel.getData(for: .notificationSettings) {
      

                let mainSectionItems:[NotificationItem] = [.goToSettingsModel(title: firstСombination.0, imageName: "gear")]
            
                let soundsSettingsSectionItems:[NotificationItem] = [.switchModelData(info: NotificationCellModel(title: firstСombination.1 , isSelect:                 notificationSettings.sound))]
            
                let otherSectionItems:[NotificationItem] = [.switchModelData(info: NotificationCellModel(title: firstСombination.3, isSelect: notificationSettings.completion)),.switchModelData(info: NotificationCellModel(title: firstСombination.4, isSelect: notificationSettings.cancellation))]
            
                self.items.onNext([NotificationSection(model: .main(header: nil, footer: firstСombination.2), items: mainSectionItems),NotificationSection(model: .other(header: secondСombination.1, footer: firstСombination.5), items: soundsSettingsSectionItems),NotificationSection(model: .other(header: secondСombination.0, footer: firstСombination.6 ), items: otherSectionItems)])
            }
        }).disposed(by: disposeBag)
       
    }
    
    struct Input {
        let changeValueIndex:Observable<ChangeSwitchCaseModel>
        let selectCell:Observable<IndexPath>

    }
    struct Output {
        let items:Driver<[NotificationSection]>
        let title:Driver<String>
    }
    
    init() {
        getTableData()
    }
}








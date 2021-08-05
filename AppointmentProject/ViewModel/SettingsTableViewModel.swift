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
        return Localizable.localize(.language).asDriver(onErrorJustReturn: "")
    }
    
    private var tableDataDriver:Driver<[ModelSettingCell]> {
        return tableData.asDriver(onErrorJustReturn: [])
    }
    
}
class SettingsTableViewModel: ViewModelProtocol {
    private let disposeBag = DisposeBag()
    private let tableData = BehaviorSubject<[ModelSettingCell]>(value: [])
  
    
    func transform(_ input: Input) -> Output {
        getTableData()
        selectCell(input)
        return Output(tableData: tableDataDriver, titleSettings: titleSettings)
    }
    
    func getTableData() {
        SingletonData.shared.languageIndex.flatMapFirst { index -> Observable<[ModelSettingCell]> in
            var createData :[ModelSettingCell] = []
            for (indexLoc,value) in SingletonData.shared.arrayLanguage.enumerated() {
                createData.append(ModelSettingCell(nameLanguage: value, isSelect: index == indexLoc))
            }
            
            return Observable<[ModelSettingCell]>.just(createData)
        }.subscribe(tableData).disposed(by: disposeBag)
        
    }
    func selectCell(_ input: Input) {
        input.selectCell.subscribe(onNext: { newIndex in
            SingletonData.shared.languageIndex.accept(newIndex)
        }).disposed(by: disposeBag)
    }
    struct Input {
        let selectCell:Observable<Int>
        
    }
    struct Output {
        let tableData:Driver<[ModelSettingCell]>
        let titleSettings:Driver<String>
    }
    
}

struct ModelSettingCell {
    let nameLanguage:String
    let isSelect:Bool
}



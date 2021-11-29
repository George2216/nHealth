//
//  LanguageTVM.swift
//  AppointmentProject
//
//  Created by George on 05.08.2021.
//

import Foundation
import RxSwift
import RxCocoa
extension LanguageTVM {
    private var tableDataDriver:Driver<[ModelLanguageCell]> {
        return tableData.asDriverOnErrorJustComplete()
    }
    
}
final class LanguageTVM: ViewModelProtocol {
    private let disposeBag = DisposeBag()
    private var titleSettingsLanguage:Driver<String> {
        return Localizable.localize(.language).asDriver(onErrorJustReturn: "")
    }
    
    private let tableData = BehaviorSubject<[ModelLanguageCell]>(value: [])

    func transform(_ input: Input) -> Output {
        getTableData()
        selectCell(input)
       return  Output(tableData: tableDataDriver, titleSettings: titleSettingsLanguage)
    }
    struct Input {
        let selectCell:Observable<Int>
    }
    struct Output {
        let tableData:Driver<[ModelLanguageCell]>
        let titleSettings:Driver<String>


    }
    
    private func selectCell(_ input: Input) {
        input.selectCell.subscribe(onNext: { newIndex in
            SingletonData.shared.languageIndex.accept(newIndex)
        }).disposed(by: disposeBag)
    }
    
    private func getTableData() {
        SingletonData.shared.languageIndex.flatMapFirst { index -> Observable<[ModelLanguageCell]> in
            var createData :[ModelLanguageCell] = []
            for (indexLoc,value) in SingletonData.shared.arrayLanguage.enumerated() {
                createData.append(ModelLanguageCell(nameLanguage: value, isSelect: index == indexLoc))
            }
            
            return Observable<[ModelLanguageCell]>.just(createData)
        }.subscribe(tableData).disposed(by: disposeBag)
    }
}



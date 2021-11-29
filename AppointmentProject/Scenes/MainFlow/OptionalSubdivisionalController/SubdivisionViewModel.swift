//
//  SubdivisionViewModel.swift
//  AppointmentProject
//
//  Created by George on 15.07.2021.
//

import Foundation
import RxSwift
import RxCocoa
extension SubdivisionViewModel {
    private var subdivisionContentDriver:Driver<[CenterListModel]> {
        return subdivisionContent.asDriver(onErrorJustReturn: [])
    }
    private var selectCellDriver:Driver<(name:String,id:String)> {
        return selectCell.asDriver(onErrorJustReturn: (name: "", id: ""))
    }
    private var subdivisionTitle:Driver<String> {
        return Localizable.localize(.subdivision).asDriver(onErrorJustReturn: "")
    }
}

class SubdivisionViewModel: ViewModelProtocol {
    private let disposeBag = DisposeBag()
    private var subdivisionContent = BehaviorSubject<[CenterListModel]>(value: [])
    private var selectCell = PublishSubject<(name:String,id:String)>()
    
    func transform(_ input: Input) -> Output {
        getSubdvision()
        getCellSelectData(input)
        
        return Output(subdvisionContent: subdivisionContentDriver, selectCellData: selectCellDriver, tapCancel: input.tapCancel.asDriver(onErrorJustReturn: ()), subdivisionTitle: subdivisionTitle)
    }
    func getSubdvision() {
        if let subdivision = CentersListModel.getData(for: .Subdivisions) {
            self.subdivisionContent.onNext(subdivision.Center)
        }
    }
    
    private func getCellSelectData(_ input:Input) {
        
        input.selectCell.withLatestFrom( Observable.combineLatest(input.selectCell, subdivisionContent)).subscribe(onNext:{[self] row , subdvissionData in
            selectCell.onNext((name: subdvissionData[row].name , id: subdvissionData[row].id ))
        }).disposed(by: disposeBag)
        
                                        
    }
    struct Input {
        let selectCell:Observable<Int>
        let tapCancel:Observable<Void>
    }
    
    struct Output {
        let subdvisionContent:Driver<[CenterListModel]>
        let selectCellData:Driver<(name:String,id:String)>
        let tapCancel:Driver<Void>
        let subdivisionTitle:Driver<String>


    }
}

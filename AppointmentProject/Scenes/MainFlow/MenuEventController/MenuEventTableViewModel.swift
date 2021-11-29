//
//  MenuEventTableViewModel.swift
//  AppointmentProject
//
//  Created by George on 02.08.2021.
//

import Foundation
import RxSwift
import RxCocoa


extension MenuEventTableViewModel {
    private var myActionDriver:Driver<SelectAction> {
        return myAction.asDriverOnErrorJustComplete()
    }

}
final class MenuEventTableViewModel: ViewModelProtocol {
    let disposeBag = DisposeBag()
    let myAction = PublishSubject<SelectAction>()

    let arrayData = BehaviorSubject<[ModelMenuCell]>(value: [])
    func transform(_ input: Input) -> Output {
        createCellData()
        subscribeOnCellSelected(input)
        return Output(cellsData: arrayData.asDriver(onErrorJustReturn: []), myAction: myActionDriver)
    }
  private func createCellData() {
        Observable.combineLatest(Localizable.localize(.delete), Localizable.localize(.goToDoctor)).subscribe(onNext:{ delete , goToDoc in
            var cellsArrray:[ModelMenuCell] = []
            let deleteCel = ModelMenuCell(title: delete, image: "minus.circle.fill")
            let goToDocCell = ModelMenuCell(title: goToDoc, image: "arrowshape.turn.up.forward.fill")
            cellsArrray.append(deleteCel)
            cellsArrray.append(goToDocCell)

            self.arrayData.onNext(cellsArrray)
        }).disposed(by: disposeBag)
    }
    private func subscribeOnCellSelected(_ input:Input) {
        input.selectIndex.subscribe(onNext:{ [self]row in
            switch row {
            case 0 : myAction.onNext(.delete)
            case 1 : myAction.onNext(.goToDoctor)
                
            default:break
            }
        }).disposed(by: disposeBag)
    }
    
    struct Input {
        let selectIndex:Observable<Int>
    }
    
    struct Output {
        let cellsData:Driver<[ModelMenuCell]>
        let myAction:Driver<SelectAction>
    }
    
    
}

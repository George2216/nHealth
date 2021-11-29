//
//  PageDoctorViewModel.swift
//  AppointmentProject
//
//  Created by George on 25.08.2021.
//

import Foundation
import RxSwift
import RxCocoa

extension PageDoctorViewModel{
    private  var isShowBarFlagDriver:Driver<Bool> {
        return isShowBarFlag.asDriverOnErrorJustComplete()
    }
}
class PageDoctorViewModel: ViewModelProtocol {
    private let disposeBag = DisposeBag()
  
    private var isShowBarFlag = BehaviorSubject<Bool>(value: false)
   
    func transform(_ input: Input) -> Output {
        subscribeOnTapView(input)
        return Output(isShowBarFlag: isShowBarFlagDriver)
    }
    
    private func subscribeOnTapView(_ input: Input) {
        input.tapViewAction.withLatestFrom(isShowBarFlag).subscribe(onNext:  {flag in
            self.isShowBarFlag.onNext(!flag)
        }).disposed(by: disposeBag)
    }
  
    
    struct Input {
        let tapViewAction:Observable<Void>
    }
    
    struct Output {
        let isShowBarFlag:Driver<Bool>
    }
    
    
}

struct ImagesHelper {
    var imageId = String()
    var imageData:String?
}

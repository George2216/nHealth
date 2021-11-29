//
//  PageViewModel.swift
//  AppointmentProject
//
//  Created by George on 23.08.2021.
//

import Foundation
import RxSwift
import RxCocoa

extension PageViewModel {
    private var arrayImageNameDriver:Driver<[String]> {
        return  arrayImageName.asDriver(onErrorJustReturn: [])
    }
    private var titleTextDriver:Driver<String> {
        return  titleText.asDriver(onErrorJustReturn: "")
    }
    private var isDisplayedBarsDriver:Driver<Bool> {
        return  isDisplayedBars.asDriver(onErrorJustReturn: false)
    }
}
class PageViewModel: ViewModelProtocol {
    private let titleText = BehaviorSubject<String>(value: "")
    private let disposeBag = DisposeBag()
    private let arrayImageName = BehaviorSubject<[String]>(value: ["im3","im1","im3","im3"])
    private let isDisplayedBars = BehaviorSubject<Bool>(value: false)
    func transform(_ input: Input) -> Output {
        createTitle(input)
        subscrbeOnDisplayedBars(input)
        return Output(arrayImageName: arrayImageNameDriver, titleText: titleTextDriver, isDisplayedBars: isDisplayedBarsDriver)
    }
    private func createTitle(_ input: Input) {
        input.displayedImageCell.withLatestFrom( Observable.combineLatest(input.displayedImageCell, arrayImageName, Localizable.localize(.of)))
            .subscribe(onNext: { displayedIndex , arrayImageName , ofText in
            self.titleText.onNext("\(displayedIndex + 1) \(ofText) \(arrayImageName.count)" )
        }).disposed(by: disposeBag)
    }
    private func subscrbeOnDisplayedBars(_ input: Input) {
        input.tapOnView.withLatestFrom(isDisplayedBars).subscribe(onNext: { isDisplayed in
            self.isDisplayedBars.onNext(!isDisplayed)
        }).disposed(by: disposeBag)
        
    }
    struct Input {
        let displayedImageCell:Observable<Int>
        let tapOnView:Observable<Void>
    }
    struct Output {
        let arrayImageName:Driver<[String]>
        let titleText:Driver<String>
        let isDisplayedBars:Driver<Bool>
    }
}

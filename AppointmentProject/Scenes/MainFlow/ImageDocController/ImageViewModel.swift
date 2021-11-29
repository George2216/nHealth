//
//  ImageViewModel.swift
//  AppointmentProject
//
//  Created by George on 26.08.2021.
//

import Foundation
import RxSwift
import RxCocoa
extension ImageViewModel {
    private var imageDataDriver:Driver<String> {
        return imageData.asDriver(onErrorJustReturn: "")
    }
}
class ImageViewModel: ViewModelProtocol {
    private let disposeBag = DisposeBag()
    private let imageData = BehaviorSubject<String>(value: "")
    func transform(_ input: Input) -> Output {
        input.idImage.subscribe(imageData).disposed(by: disposeBag)
        return Output(imageData: imageDataDriver)
    }
    struct Input {
        let idImage:Observable<String>
    }
    struct Output {
        let imageData:Driver<String>
    }
    
}

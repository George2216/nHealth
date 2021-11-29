//
//  MapViewModel.swift
//  AppointmentProject
//
//  Created by George on 15.07.2021.
//

import Foundation
import RxSwift
import RxCocoa
extension MapViewModel {
    private var latitudeDriver:Driver<Double> {
        return latitude.asDriverOnErrorJustComplete()
    }
    private var longitudeDriver:Driver<Double> {
        return longitude.asDriverOnErrorJustComplete()
    }
    private var titleDriver:Driver<String> {
        return title.asDriverOnErrorJustComplete()
    }
    private var subtitleDriver:Driver<String> {
        return subtitle.asDriverOnErrorJustComplete()
    }
    private var titleText:Driver<String> {
        return Localizable.localize(.map).asDriverOnErrorJustComplete()
    }

}
final class MapViewModel: ViewModelProtocol {
    private let disposeBag = DisposeBag()
    private var latitude = BehaviorSubject<Double>(value: 0)
    private var longitude = BehaviorSubject<Double>(value: 0)
    private var title = BehaviorSubject<String>(value: "")
    private var subtitle = BehaviorSubject<String>(value: "")
    
    struct Input {
        let latitude:Observable<String>
        let longitude:Observable<String>
        let title:Observable<String>
        let subtitle:Observable<String>
    }
    struct Output {
        let latitude:Driver<Double>
        let longitude:Driver<Double>
        let title:Driver<String>
        let subtitle:Driver<String>
        let titleText:Driver<String>
    }
    
    func transform(_ input: Input) -> Output {
                convertCoordinateDate(input)
        return Output(latitude: latitudeDriver, longitude: longitudeDriver,title: titleDriver,subtitle: subtitleDriver, titleText: titleText)
    }
    private func convertCoordinateDate(_ input:Input) {
        input.latitude.map {Double($0) ?? 0}.bind(to: latitude).disposed(by: disposeBag)
        input.longitude.map {Double($0) ?? 0}.bind(to: longitude).disposed(by: disposeBag)
        input.title.bind(to: title).disposed(by: disposeBag)
        input.subtitle.bind(to: subtitle).disposed(by: disposeBag)
    }


}

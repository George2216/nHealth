//
//  CityViewModel.swift
//  AppointmentProject
//
//  Created by George on 06.10.2021.
//

import Foundation
import RxSwift
import RxCocoa

extension CityViewModel {
    private var tableItems:Driver<[TableViewSection]> {
        items.asDriver(onErrorJustReturn: [])
    }
    private var title:Driver<String> {
        Localizable.localize(.selectCity).asDriver(onErrorJustReturn: "")
    }
    private var searchControllerTitle:Driver<String> {
        Localizable.localize(.selectYourCity).asDriver(onErrorJustReturn: "")
    }
    private var showClinicForIndexDriver:Driver<Int> {
        showClinicForIndex.asDriver(onErrorJustReturn: 0)
    }
    
}
final class CityViewModel: ViewModelProtocol {
    private let disposeBag = DisposeBag()
    private var items = BehaviorSubject<[TableViewSection]>(value: [])
    private let showClinicForIndex = PublishSubject<Int>()
    private let filteringItems = BehaviorSubject<[TableViewSection]>(value: [])
    
    func transform(_ input: Input) -> Output {
        subscribeOnTapCell(input)
        return Output(items: tableItems, title: title, searchControllerTitle: searchControllerTitle, showClinicForIndex: showClinicForIndexDriver)
    }
    private func subscribeOnTapCell(_ input: Input) {
        input.selectIndexCell.subscribe(onNext: { [weak self] index in
            self?.showClinicForIndex.onNext(index)
        }).disposed(by: disposeBag)
    }
    private func createTableContet() {
        var tvsItems:[ModelCityCell] = []
        var content = [TableViewSection]()
        Cities.shared.cities.forEach { city in
            Localizable.localize(city.nameKey).subscribe(onNext: { city in
                tvsItems.append(ModelCityCell(text: city))
            }).disposed(by: disposeBag)
        }
        Localizable.localize(.cityHeader).subscribe(onNext:{  cityHeader in
            content = [TableViewSection(items:  tvsItems, header: cityHeader, footer: nil)]
        }).disposed(by: disposeBag)
        
        items.onNext(content)
        filteringItems.onNext(content)
    }
  

    struct Input {
        let selectIndexCell:Observable<Int>
    }
    struct Output {
        let items:Driver<[TableViewSection]>
        let title:Driver<String>
        let searchControllerTitle:Driver<String>
        let showClinicForIndex:Driver<Int>
    }
    init() {
        createTableContet()
    }
}



//
//  StockViewModel.swift
//  AppointmentProject
//
//  Created by George on 11.11.2021.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources

enum DiscountSectionType {
    case defaultSection(header:String,footer:String)
    
    var headerFooter:(header:String,footer:String) {
        switch self {
        case .defaultSection(let header, let footer):
            return (header,footer)
        }
    }
}

enum DiscountItem {
    case discountModel(info:DiscountItemModel)
}

typealias DiscountSection = SectionModel<DiscountSectionType,DiscountItem>

final class DiscountViewModel: ViewModelProtocol {
    private let disposeBag = DisposeBag()
    private let items = BehaviorSubject<[DiscountSection]>(value:[])
    
    func transform(_ input: Input) -> Output {
        return Output(contentTable: tableData,titleText:titleText)
    }
    
    struct Input {
        
    }
    struct Output {
        let contentTable:Driver<[DiscountSection]>
        let titleText:Driver<String>

    }
    private func getDiscountTableData() {
        let jsonManager = JsonApiManager()
        let outputJson = jsonManager.send(parametrs: .stosks, data: .none) as Observable<DiscountModel?>
        
        outputJson.subscribe(onNext: { [weak self] data in
            guard let self = self else { return }
            guard let serverOutput = data else { return }
            let contentTable = serverOutput.data.map({ item -> DiscountSection  in
                
                return DiscountSection(model: .defaultSection(header: item.name, footer: String(item.price) + " " + "₴"), items: [.discountModel(info: item)])
            })
            
            self.items.onNext(contentTable)
            
        }).disposed(by: disposeBag)
    }
    
  
    
    init(){
        getDiscountTableData()
    }
}



extension DiscountViewModel {
    
    private var tableData:Driver<[DiscountSection]> {
        items.asDriverOnErrorJustComplete()
    }
    private var titleText:Driver<String> {
        Localizable.localize(.discount).asDriverOnErrorJustComplete()
    }
}

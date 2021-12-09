//
//  ClinicViewModel.swift
//  AppointmentProject
//
//  Created by George on 07.10.2021.
//

import RxSwift
import RxCocoa
import Foundation
import CoreData
extension ClinicViewModel {
    private var tableItems:Driver<[TableViewSection]> {
        items.asDriverOnErrorJustComplete()
    }
    private var title:Driver<String> {
        Localizable.localize(.selectClinic).asDriverOnErrorJustComplete()
    }
    private var searchControllerTitle:Driver<String> {
        Localizable.localize(.selectYourClinic).asDriverOnErrorJustComplete()
    }
    private var goToMainFlowDriver:Driver<Void> {
        goToMainFlow.asDriverOnErrorJustComplete()
    }
    private var showActivityIndicatiorDriver:Driver<Void> {
        showActivityIndicatior.asDriverOnErrorJustComplete()
    }
    private var hideActivityIndicatiorDriver:Driver<Void> {
        hideActivityIndicatior.asDriverOnErrorJustComplete()
    }
    private var connectionErrorDriver:Driver<String> {
        connectionError.asDriverOnErrorJustComplete()
    }
}

final class ClinicViewModel: ViewModelProtocol {
    private let disposeBag = DisposeBag()
    private let items = BehaviorSubject<[TableViewSection]>(value: [])
    private let cityIndex = BehaviorSubject<Int>(value: 0)
    private let goToMainFlow = PublishSubject<Void>()
    private let showActivityIndicatior = PublishSubject<Void>()
    private let hideActivityIndicatior = PublishSubject<Void>()
    private let connectionError = PublishSubject<String>()
    private let connectionErrorMessage = Localizable.localize(.connectionError)
    func transform(_ input: Input) -> Output {
        subscribeOnCityIndex(input)
        subscribeOnSelectClinc(input)
        return Output(items: tableItems,title:title, searchControllerTitle: searchControllerTitle, goToMainFlow: goToMainFlowDriver, showActivityIndicatior: showActivityIndicatiorDriver, hideActivityIndicatior: hideActivityIndicatiorDriver, connectionError: connectionErrorDriver)
    }
 
    private func subscribeOnCityIndex(_ input: Input) {
    input.cityIndex.withLatestFrom(Observable.combineLatest(input.cityIndex,Localizable.localize(.clinicHeader), Localizable.localize(.clinicFooter)))
        .subscribe(onNext:{ [weak self] index, header , footer  in
        guard let self = self else { return }
    let clinics =  Cities.shared.cities[index].clinics
    let items = clinics.map{ModelCityCell(text: $0.name)}
    let content = [TableViewSection(items:  items, header: header, footer: footer)]
        self.items.onNext(content)
        // saving index
        self.cityIndex.onNext(index)
    }).disposed(by: disposeBag)
    }
    
    private func subscribeOnSelectClinc(_ input: Input) {
        input.clinicSelectIndex.withLatestFrom(Observable.combineLatest(input.clinicSelectIndex,cityIndex)).subscribe(onNext: {[weak self] clinicIndex , cityIndex in
            guard let self = self else { return }
            let clinic = Cities.shared.cities[cityIndex].clinics[clinicIndex]
            
            UserDefaults.standard.setValue(clinic.token, forKey: UDKeys.requestToken.rawValue)
            UserDefaults.standard.setValue(clinic.urlString, forKey: UDKeys.urlPath.rawValue)
            
            self.showActivityIndicatior.onNext(())
            self.getCenterList(token: clinic.token, clinic:clinic)
            
        }).disposed(by: disposeBag)
       
    }
    private func getCenterList(token:String,clinic:ClinicProtocol) {
        let apiManager = XMLMultiCoder<CentersListModel>()
        let inputData = InputModelCentersList(Token:token)
        
        
        Observable.zip(apiManager.parsData(input: inputData, metod: .POST, phpFunc: .CenterList, ecodeParam: EncodeParam(withRootKey: "Root", rootAttributes: nil, header: nil)).asObservable(), connectionErrorMessage)
            .subscribe(onNext: { [weak self] centerList , errorText in
            // save on data forma
            guard let self = self else { return }
                
           
                
            self.hideActivityIndicatior.onNext(())

            if  let centerList = centerList.0 {
                
            centerList.saveSelfData(for: .Subdivisions)
            
            DispatchQueue.global().asyncAfter(deadline: .now() + .milliseconds(500)) {
                self.goToMainFlow.onNext(())
            }
                
            } else {
                DispatchQueue.global().asyncAfter(deadline: .now() + .milliseconds(500)) {
                self.connectionError.onNext(errorText)
                }
            }
            
        }).disposed(by: disposeBag)
    }
    struct Input {
        let cityIndex:Observable<Int>
        let clinicSelectIndex:Observable<Int>
    
    }
    struct Output {
        let items:Driver<[TableViewSection]>
        let title:Driver<String>
        let searchControllerTitle:Driver<String>
        let goToMainFlow:Driver<Void>
        let showActivityIndicatior:Driver<Void>
        let hideActivityIndicatior:Driver<Void>
        let connectionError:Driver<String>
    }
    
}



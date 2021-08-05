//
//  TableViewDoctorViewModel.swift
//  AppointmentProject
//
//  Created by George on 27.07.2021.
//

import Foundation
import RxCocoa
import RxSwift

extension TableViewDoctorViewModel {
   private var doctorDataDriver:Driver<DetailDoctorModel> {
        return  doctorData.asDriver(onErrorJustReturn: DetailDoctorModel(name: "", professions: "", subdivision: "", subdivisionAdress: ""))
    }
    
    private var collectionDataDriver:Driver<[String]> {
        return collectionData.asDriver(onErrorJustReturn: [])
    }
    private var coordinateDataDriver:Driver<(latitude:String,longitude:String,title:String,subtitle:String)> {
        return coordinateDataEvent.asDriver(onErrorJustReturn: (latitude: String(), longitude: String(), title: String(), subtitle: String()))
    }
    private var titleText:Driver<String> {
        return Localizable.localize(.doctor).asDriver(onErrorJustReturn: "")
    }
    private var subdivisionText:Driver<String> {
        return Localizable.localize(.subdivision).asDriver(onErrorJustReturn: "")
    }
    private var professionsText:Driver<String> {
        return Localizable.localize(.professions).asDriver(onErrorJustReturn: "")
    }
    private var singUpText:Driver<String> {
        return Localizable.localize(.signUp).map{$0 + ":" }.asDriver(onErrorJustReturn: "")
    }
    
    private var tapBackButtonDriver:Driver<Void> {
        return tapBackButton.asDriver(onErrorJustReturn: ())
    }
    private var localeKey:Driver<String> {
        return Localizable.languageKey().asDriver(onErrorJustReturn: "")
    }
    
}

class TableViewDoctorViewModel: ViewModelProtocol {
    private let disposeBag = DisposeBag()
    private let collectionData = BehaviorSubject<[String]>(value:[])
    private let selectDate = BehaviorSubject<Date>(value: Date())
    private let doctorData = PublishSubject<DetailDoctorModel>()
    private let inputDocData = BehaviorSubject<ParamDoctor>(value: ParamDoctor(id: "", name: "", CenterId: "", SpecId: []))
    private let coordinateDataSave = BehaviorSubject<(latitude:String,longitude:String,title:String,subtitle:String)>(value: (latitude: String(), longitude: String(), title: String(), subtitle: String()))
    
    private let coordinateDataEvent = PublishSubject<(latitude:String,longitude:String,title:String,subtitle:String)>()
   
    private var tapBackButton = PublishSubject<Void>()
    
    func transform(_ input: Input) -> Output {
        
        createContentTable(input)
        getCollectionData(input)
        subscribeOnTouchAdress(input)
        subcribses(input)
        
        return Output(doctorData: doctorDataDriver, collectionData: collectionDataDriver, coordinateData: coordinateDataDriver,titleText:titleText,subdivisionText:subdivisionText, professionsText: professionsText, singUpText: singUpText, popBack: tapBackButtonDriver, localeKey: localeKey)
    }
    
    private func subcribses(_ input: Input) {
        input.selectDate.bind(to: selectDate).disposed(by: disposeBag)
        input.tapBackButton.subscribe(tapBackButton).disposed(by: disposeBag)
    }
    
    private func subscribeOnTouchAdress(_ input: Input) {
        input.selectAdress.withLatestFrom(coordinateDataSave).subscribe(onNext: { data in
            self.coordinateDataEvent.onNext(data)
        }).disposed(by: disposeBag)
        
      
    }
    private func createContentTable(_ input:Input) {
        
        input.doctorParametrs.subscribe(onNext: { [self] parametrs in
            inputDocData.onNext(parametrs)
            guard let subdivision:CentersListModel = SingletonData.shared.getCentersListData() else {
                    return
                }
            let professionName = parametrs.SpecId.map{$0.name}.joined(separator: ", ")
            var subdivisionAdress = ""
            var subdivisionName = ""
            
            subdivision.Center.forEach { model in
                if model.id == parametrs.CenterId {
                    subdivisionAdress =  model.city + ", " + model.address
                    subdivisionName = model.name
                    coordinateDataSave.onNext((latitude: model.latitude, longitude: model.longitude, title: model.name, subtitle: model.city + ", " + model.address))
                    return
                }
            }
            
            let detailDoctor = DetailDoctorModel(name: parametrs.name, professions: professionName, subdivision: subdivisionName, subdivisionAdress: subdivisionAdress)
            doctorData.onNext(detailDoctor)
        }).disposed(by: disposeBag)
    }
    
    private func getCollectionData(_ input:Input) {
        selectDate.withLatestFrom(Observable.combineLatest(inputDocData, input.selectDate)).subscribe(onNext: { [self]
            docData , date in
        
            let apiInput = InputModelSlots(Token: "EEF4B03D-C023", CenterId: docData.CenterId, Date: date.stringDateSpase(), DoctorId: docData.id, Duration: "30")
                self.collectionSlotsRequest(input: apiInput)
            
        }).disposed(by: disposeBag)
        
    }
    private func collectionSlotsRequest(input:InputModelSlots) {
        let apiManager = XMLMultiCoder<SlotsByDocDayModel>()
        apiManager.parsData(input: input, metod: .POST, phpFunc: .SlotsByDocDay, ecodeParam: EncodeParam(withRootKey: "Root", rootAttributes: nil, header: nil)).asObservable().subscribe(onNext: { model , _  in
            
            var arraySlots:[String] = []
            
            if model?.Windows.count != 0 , let window = model?.Windows[0].Window  {
            
            
            for slot in window {
                arraySlots.append(slot.Start.cutString(from: 11, to: 15))
            }
            self.collectionData.onNext(arraySlots)
            } else {
                
            self.collectionData.onNext([])
            }
        }).disposed(by: self.disposeBag)

    }
    struct Input {
        let doctorParametrs:Observable<ParamDoctor>
        let selectDate:Observable<Date>
        let selectAdress:Observable<Void>
        let tapBackButton:Observable<Void>
    }
    struct Output {
        let doctorData:Driver<DetailDoctorModel>
        let collectionData:Driver<[String]>
        let coordinateData:Driver<(latitude:String,longitude:String,title:String,subtitle:String)>
        let titleText:Driver<String>
        let subdivisionText:Driver<String>
        let professionsText:Driver<String>
        let singUpText:Driver<String>
        let popBack:Driver<Void>
        let localeKey:Driver<String>
    }
}

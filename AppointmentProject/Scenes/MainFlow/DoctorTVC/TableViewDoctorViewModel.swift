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
    private var pushPagesForIdDriver:Driver<[String]> {
        return pushPagesForId.asDriverOnErrorJustComplete()
    }
    private var reloadTableDriver:Driver<Void> {
        return reloadTable.asDriverOnErrorJustComplete()
    }
   private var doctorDataDriver:Driver<DetailDoctorModel> {
        return  doctorData.asDriverOnErrorJustComplete()
    }
    
    private var collectionDataDriver:Driver<[String]> {
        return collectionData.asDriverOnErrorJustComplete()
    }
    private var coordinateDataDriver:Driver<CoordinateModel> {
        return coordinateDataEvent.asDriverOnErrorJustComplete()
    }
    private var titleText:Driver<String> {
        return Localizable.localize(.doctor).asDriverOnErrorJustComplete()
    }
  
    private var localeText:Driver<String> {
        return Localizable.localize(.locale).asDriverOnErrorJustComplete()
    }
    private var singUpText:Driver<String> {
        return Localizable.localize(.signUp).map{$0 + ":" }.asDriverOnErrorJustComplete()
    }
    
    private var tapBackButtonDriver:Driver<Void> {
        return tapBackButton.asDriverOnErrorJustComplete()
    }
    private var localeKey:Driver<String> {
        return Localizable.languageKey().asDriverOnErrorJustComplete()
    }
    private var appointmentContentDriver:Driver<AppointmentModel> {
        appointmentContent.asDriverOnErrorJustComplete()
    }
    private var showRefreshDriver:Driver<Void> {
        showRefresh.asDriverOnErrorJustComplete()
    }
    private var hideRefreshDriver:Driver<Void> {
        hideRefresh.asDriverOnErrorJustComplete()
    }
}

final class TableViewDoctorViewModel: ViewModelProtocol {
    
    private let disposeBag = DisposeBag()
    private let collectionData = BehaviorSubject<[String]>(value:[])
    private let selectDate = BehaviorSubject<Date>(value: Date())
    private let doctorData = BehaviorSubject<DetailDoctorModel>(value: DetailDoctorModel(name: "", professions: "", subdivision: "", subdivisionAdress: ""))
    private let inputDocData = BehaviorSubject<DoctorContent>(value: DoctorContent(id: "", name: "", professions: ""))
    private let coordinateDataSave = BehaviorSubject<CoordinateModel>(value:CoordinateModel())
    private let reloadTable = PublishSubject<Void>()
    private let coordinateDataEvent = PublishSubject<CoordinateModel>()
   
    private let tapBackButton = PublishSubject<Void>()
    private let pushPagesForId = PublishSubject<[String]>()
    private let windowsAppointmentContent = BehaviorSubject<[WindowsModel]>(value:[])
    private let appointmentContent = PublishSubject<AppointmentModel>()
    private let showRefresh = PublishSubject<Void>()
    private let hideRefresh = PublishSubject<Void>()
    
    func transform(_ input: Input) -> Output {
        
        createContentTable(input)
        getCollectionData(input)
        subscribeOnTouchAdress(input)
        subcribses(input)
        subscribeOnTapImage(input)
        subscribeOnSelectSlot(input)
        refreshStates(input)
        
        return Output(doctorData: doctorDataDriver, collectionData: collectionDataDriver, coordinateData: coordinateDataDriver,titleText:titleText, localeText: localeText, singUpText: singUpText, popBack: tapBackButtonDriver, localeKey: localeKey, reloadTable: reloadTableDriver, pushPagesForId: pushPagesForIdDriver, appointmentContent: appointmentContentDriver, showRefresh: showRefreshDriver, hideRefresh: hideRefreshDriver)
    }
    private func refreshStates(_ input: Input) {
        input.showRefresh.subscribe(onNext:{[weak self] in
            self?.showRefresh.onNext(())
        }).disposed(by: disposeBag)
        
        collectionData.subscribe(onNext: {[weak self] _ in
            self?.hideRefresh.onNext(())
        }).disposed(by: disposeBag)
    }
    
    
    private func subscribeOnSelectSlot(_ input: Input) {
        input.selectSlot.withLatestFrom(Observable.combineLatest(input.selectSlot,windowsAppointmentContent,inputDocData)).subscribe(onNext: {[weak self] index , windows , docData in
            guard let self = self else { return }
            let selectWindow = windows[0].Window[index]
            guard let subdivisions:CentersListModel = SingletonData.shared.getCentersListData(), !subdivisions.Center.isEmpty else { return }
            let subdivision = subdivisions.Center[0]
            
            let appointmentData = AppointmentModel(doctor: AppointmentDoctor(id: docData.id, name: docData.name, professions: docData.professions), appointmentLockation: AppointmentCenter(id: subdivision.id, latitude: subdivision.latitude, longitude: subdivision.longitude, name: subdivision.name, city: subdivision.city, adress: subdivision.address), appointmentTime: AppointmentTime(time: selectWindow.Start, roomId: selectWindow.RoomId))
            
            self.appointmentContent.onNext(appointmentData)
            
            
        }).disposed(by: disposeBag)
    }
    private func subscribeOnTapImage(_ input: Input) {
        input.tapDoctorImage.subscribe(onNext: { _ in
//            let docId = "" // get doc id and push photos
            self.pushPagesForId.onNext([])
        }).disposed(by: disposeBag)
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
        
        input.doctorParametrs.subscribe(onNext: { [weak self] parametrs in
            guard let self = self else { return }
            
            self.inputDocData.onNext(parametrs)

            guard let subdivisions:CentersListModel = SingletonData.shared.getCentersListData(), !subdivisions.Center.isEmpty else {
                    return
                }
            
            let professionName = parametrs.professions
            let subdivision = subdivisions.Center[0]

            let subdivisionAdress = subdivision.city + ", " + subdivision.address
            
            self.coordinateDataSave.onNext(CoordinateModel(latitude: subdivision.latitude, longitude: subdivision.longitude, title: subdivision.name, subtitle: subdivisionAdress))
            
            
            
            let detailDoctor = DetailDoctorModel(name: parametrs.name, professions: professionName, subdivision: subdivision.name, subdivisionAdress: subdivisionAdress)
            
            self.doctorData.onNext(detailDoctor)
        }).disposed(by: disposeBag)
    }
    
    private func getCollectionData(_ input:Input) {
        selectDate.withLatestFrom(Observable.combineLatest(inputDocData, input.selectDate)).subscribe(onNext: { [self]
            docData , date in
            guard let subdivisions:CentersListModel = SingletonData.shared.getCentersListData(), !subdivisions.Center.isEmpty else {  return  }
            
            let subdivision = subdivisions.Center[0]
            
            let apiInput = InputModelSlots(Token: SingletonData.shared.token, CenterId: subdivision.id, Date: date.stringDateSpase(), DoctorId: docData.id, Duration: "30")
                self.collectionSlotsRequest(input: apiInput)
            
        }).disposed(by: disposeBag)
    }
    
    private func collectionSlotsRequest(input:InputModelSlots) {
        let apiManager = XMLMultiCoder<SlotsByDocDayModel>()
        apiManager.parsData(input: input, metod: .POST, phpFunc: .SlotsByDocDay, ecodeParam: EncodeParam(withRootKey: "Root", rootAttributes: nil, header: nil)).asObservable().subscribe(onNext: { [self] model , _  in
            
            var arraySlots:[String] = []
            if model?.Windows.count != 0 , var window = model?.Windows[0].Window  {
            let windows = model!.Windows[0]
            window = window.filter { item in
                    let time = item.Start.changeSymbol("T", on: " ").fullDateSpase() ?? Date()
                    return time > Date()
            }
            self.windowsAppointmentContent.onNext([WindowsModel(name: windows.name, DoctorName: windows.DoctorName, DoctorId: windows.DoctorId, Date: windows.Date, Window: window)])

            for slot in window {
                arraySlots.append(slot.Start.cutString(from: 11, to: 15))
            }
            self.collectionData.onNext(arraySlots)
            } else {
                
            self.collectionData.onNext([])
            }
            reloadTable.onNext(())
        }).disposed(by: self.disposeBag)

    }
    
    struct Input {
        let doctorParametrs:Observable<DoctorContent>
        let selectDate:Observable<Date>
        let selectAdress:Observable<Void>
        let tapBackButton:Observable<Void>
        let tapDoctorImage:Observable<Void>
        let selectSlot:Observable<Int>
        let showRefresh:Observable<Void>
        
    }
    
    struct Output {
        let doctorData:Driver<DetailDoctorModel>
        let collectionData:Driver<[String]>
        let coordinateData:Driver<CoordinateModel>
        let titleText:Driver<String>
        let localeText:Driver<String>
        let singUpText:Driver<String>
        let popBack:Driver<Void>
        let localeKey:Driver<String>
        let reloadTable:Driver<Void>
        let pushPagesForId:Driver<[String]>
        let appointmentContent:Driver<AppointmentModel>
        let showRefresh:Driver<Void>
        let hideRefresh:Driver<Void>

        // show refresh
        // hide refresh
        
    }
}

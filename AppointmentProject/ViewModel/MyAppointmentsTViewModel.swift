//
//  MyAppointmentsTViewModel.swift
//  AppointmentProject
//
//  Created by George on 31.07.2021.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources

extension MyAppointmentsTViewModel {
    
    private var myAppointmentsTitleDriver:Driver<String> {
        return Localizable.localize(.appointments).asDriver(onErrorJustReturn: "")
    }
    private var itemsDriver:Driver<[TableViewSection]> {
        return items.asDriver(onErrorJustReturn: [])
    }
    private var presentMenuOnDriver:Driver<(CGRect,CGSize)> {
        return presentMenuOn.asDriver(onErrorJustReturn: (.zero, .zero))
    }
    private var historyTitleDriver:Driver<String> {
        return Localizable.localize(.history).asDriver(onErrorJustReturn: "")
    }
    private var selectDocDriver:Driver<String> {
        return selectDoc.asDriver(onErrorJustReturn: "")
    }
    private var presentReloadIndicatorDriver:Driver<Void> {
        return presentReloadIndicator.asDriver(onErrorJustReturn: ())
    }
    private var dismissReloadIndicatorDriver:Driver<Void> {
        return dismissReloadIndicator.asDriver(onErrorJustReturn: ())
    }
    
}
class MyAppointmentsTViewModel: ViewModelProtocol {
    private let indexSelectedCell = BehaviorSubject<IndexPath>(value: IndexPath())
    private let presentMenuOn = PublishSubject<(CGRect,CGSize)>()
    private let disposeBag = DisposeBag()
    private var items = BehaviorSubject<[TableViewSection]>(value: [])
    private let selectDoc = PublishSubject<String>()
    private let goToDoctor = PublishSubject<Void>()
    private let cancelAppointment = PublishSubject<(centerId:String,appointmentId:String,inputData:InputCancelAppointmentModel)>()
    private let presentReloadIndicator = PublishSubject<Void>()
    private let dismissReloadIndicator = PublishSubject<Void>()

    func transform(_ input: Input) -> Output {
        input.refreshContent.subscribe(onNext:getTableData).disposed(by: disposeBag)
        menuPosition(input)
        actionsAppointments(input)
        goToDoc()
        cancelAppointmentAction()
        
        return Output(myAppointmentsTitle: myAppointmentsTitleDriver, contentTable: itemsDriver, presentMenuOn: presentMenuOnDriver, historyTitle: historyTitleDriver, selectDoc: selectDocDriver,presentReloadIndicator:presentReloadIndicatorDriver, dismissReloadIndicator: dismissReloadIndicatorDriver)
    }
    
  
    private func getTableData() {
        if let appointmentsData = UserDefaults.standard.data(forKey: UDKeys.appointments.rawValue) {
            
            guard let appointments:MyAppointmentsModel = getPacketFromData(data: appointmentsData) else {
                return
            }
               var contentTable = appointments.myAppoints.map { content -> TableViewSection in
                    
                let contentCell = ModelAppointmentCell(subdivision: content.subdivision, doctorName: content.name, doctorProfession: content.professions, appointmentID: content.appointmentId, centerId: content.centerId, docId: content.docId)
                
                
                    return TableViewSection(items: [contentCell], header: content.time)
               }
            
            contentTable = contentTable.sorted { firstModel , secondModel in
                let firstDate = firstModel.header.dateSpace() ?? Date()
                let secondDate = secondModel.header.dateSpace() ?? Date()

                return firstDate > secondDate
               }
            
            items.onNext(contentTable)
        }
       
    }
    private func actionsAppointments(_ input: Input) {
        input.selectAction.withLatestFrom(Observable.combineLatest(items, indexSelectedCell, input.selectAction)).subscribe(onNext: { [self]contentTable , index , action in
            let content = contentTable[index.section].items[index.row] as! ModelAppointmentCell
            
            let inputData = InputCancelAppointmentModel(Token: "EEF4B03D-C023", CenterId: content.centerId, AppointmentId: content.appointmentID)
//            let request = apiManager.parsData(input: inputData, metod: .POST, phpFunc: .CancelAppointment, ecodeParam: EncodeParam(withRootKey: nil, rootAttributes: nil, header: nil))

            switch action {
            case .delete:cancelAppointment.onNext((centerId: content.centerId, appointmentId: content.appointmentID,inputData:inputData))
            case .goToDoctor: goToDoctor.onNext(())
            }
        }).disposed(by: disposeBag)
    }
    private func menuPosition(_ input: Input) {
        input.itemSelectedOn.subscribe(onNext: { position in
            self.indexSelectedCell.onNext(position.indexPath)
            let rect = CGRect(x: 50, y: position.topY - 50 , width: 0, height: 0)
            let size = CGSize(width: 300, height: 100)
            self.presentMenuOn.onNext((rect, size))
        }).disposed(by: disposeBag)
        
       
    }
    
    private func goToDoc() {
        goToDoctor.throttle(.seconds(1), scheduler: MainScheduler.instance).withLatestFrom(Observable.combineLatest(indexSelectedCell, items)).subscribe(onNext: { index , items in
            let contentDoc =             items[index.section].items[index.row] as? ModelAppointmentCell
            self.selectDoc.onNext(contentDoc?.docId ?? "")
        }).disposed(by: disposeBag)
    
    }
    
    // delete appointment from server and memory
    private func cancelAppointmentAction() {
        cancelAppointment.flatMapLatest { (centerId , appointmentId, input ) -> Observable<String?> in
            let apiManager = XMLMultiCoder<AppointmentOutput>()
            self.presentReloadIndicator.onNext(())
            
            
        let request = apiManager.parsData(input: input, metod: .POST, phpFunc: .CancelAppointment, ecodeParam: EncodeParam(withRootKey: "Root", rootAttributes: nil, header: nil))
            
            return request.map{$0.1}
            
        }.subscribe(onNext: { response in
            
            if let appointmentsData = UserDefaults.standard.data(forKey: UDKeys.appointments.rawValue), let response = response {
                
                guard let appointments:MyAppointmentsModel = getPacketFromData(data: appointmentsData) else {
                    return
                }
                
                let newAppointments = appointments.myAppoints.filter{$0.appointmentId != response }
                
                guard let appoinmnebtsNewData = getDataFromPacket(packet: MyAppointmentsModel(myAppoints: newAppointments)) else {
                    return
                }

                UserDefaults.standard.setValue(appoinmnebtsNewData, forKey: UDKeys.appointments.rawValue)
                
                DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(1)) { [self] in
                    self.dismissReloadIndicator.onNext(())
                    self.getTableData()
                }
                
            } else {
                DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(1)) { [self] in
                    self.dismissReloadIndicator.onNext(())
                    self.getTableData()
                }
                print("Error")
            }
            
        }).disposed(by: disposeBag)
        
        
    }
    struct Input {
        let refreshContent:Observable<Void>
        let itemSelectedOn:Observable<ModelCellPosition>
        let selectAction:Observable<SelectAction>
    }
    
    struct Output {
        let myAppointmentsTitle:Driver<String>
        let contentTable:Driver<[TableViewSection]>
        let presentMenuOn:Driver<(CGRect,CGSize)>
        let historyTitle:Driver<String>
        let selectDoc:Driver<String>
        let presentReloadIndicator:Driver<Void>
        let dismissReloadIndicator:Driver<Void>
    }
}

